"""Generate PDF reports for quiz attempts."""
import io
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.lib.colors import HexColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Preformatted
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

from ..models import User


def generate_attempt_pdf(
    user: User,
    attempt_data: dict,
    questions: list[dict],
) -> bytes:
    """Generate a PDF report for a quiz attempt."""
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, topMargin=1.5*cm, bottomMargin=1.5*cm)
    
    # Register Noto Sans Bengali for Unicode support
    try:
        pdfmetrics.registerFont(TTFont('NotoSansBengali', '/usr/share/fonts/truetype/noto/NotoSansBengali-Regular.ttf'))
        font_name = 'NotoSansBengali'
    except:
        font_name = 'Helvetica'
    
    styles = getSampleStyleSheet()
    pre_style = ParagraphStyle(
        'PreWrap',
        parent=styles['Normal'],
        fontName=font_name,
        fontSize=9,
        leading=12,
        leftIndent=0,
        wordWrap='CJK',
    )
    
    story = []
    
    # Student info
    story.append(Paragraph(f"<b>Student:</b> {user.display_name}", styles['Normal']))
    story.append(Paragraph(f"<b>Email:</b> {user.email}", styles['Normal']))
    
    submitted_at = attempt_data.get('submitted_at')
    if submitted_at:
        if isinstance(submitted_at, str):
            submitted_at = datetime.fromisoformat(submitted_at)
        submitted_str = submitted_at.strftime('%Y-%m-%d %H:%M')
    else:
        submitted_str = 'N/A'
    
    story.append(Paragraph(f"<b>Submitted:</b> {submitted_str}", styles['Normal']))
    story.append(Spacer(1, 0.5*cm))
    
    # Title
    story.append(Paragraph("Quiz Result", styles['Heading1']))
    story.append(Spacer(1, 0.3*cm))
    
    # Score summary
    correct = attempt_data.get('score_correct', 0)
    total = attempt_data.get('score_total', 0)
    pct = round((correct / total * 100)) if total > 0 else 0
    incorrect = len([q for q in questions if q.get('selected_label') and not q.get('is_correct')])
    skipped = len([q for q in questions if not q.get('selected_label')])
    
    summary_data = [
        ['Score', 'Correct', 'Incorrect', 'Skipped'],
        [f"{correct}/{total} ({pct}%)", str(correct), str(incorrect), str(skipped)]
    ]
    
    summary_table = Table(summary_data, colWidths=[4*cm, 3*cm, 3*cm, 3*cm])
    summary_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), HexColor('#64748b')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (0, 1), HexColor('#f8fafc')),
        ('BACKGROUND', (1, 1), (1, 1), HexColor('#dcfce7')),
        ('BACKGROUND', (2, 1), (2, 1), HexColor('#fee2e2')),
        ('BACKGROUND', (3, 1), (3, 1), HexColor('#f8fafc')),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
    ]))
    story.append(summary_table)
    story.append(Spacer(1, 0.8*cm))
    
    # Questions review
    story.append(PageBreak())
    story.append(Paragraph("<b>Detailed Review</b>", styles['Heading2']))
    story.append(Spacer(1, 0.3*cm))
    
    for idx, q in enumerate(questions, 1):
        # Question header
        story.append(Paragraph(f"<b>Q{idx}.</b>", styles['Normal']))
        story.append(Preformatted(q.get('question_text', '')[:500], pre_style))
        story.append(Spacer(1, 0.2*cm))
        
        # Options
        for opt in q.get('options', []):
            is_correct = q.get('correct_answer') == opt['label']
            is_picked = q.get('selected_label') == opt['label']
            
            marker = ''
            if is_correct:
                marker = ' [CORRECT]'
            elif is_picked:
                marker = ' [WRONG]'
            
            story.append(Preformatted(f"{opt['label']}. {opt['text'][:200]}{marker}", pre_style))
        
        # Gemini solution
        if q.get('gemini_solution'):
            story.append(Spacer(1, 0.2*cm))
            story.append(Paragraph("<b>AI Solution:</b>", styles['Normal']))
            story.append(Preformatted(q['gemini_solution'][:800], pre_style))
        
        story.append(Spacer(1, 0.4*cm))
    
    doc.build(story)
    return buffer.getvalue()
