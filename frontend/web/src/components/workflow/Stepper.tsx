type Step = 'upload' | 'clean' | 'crop' | 'extract';

interface StepperProps {
  currentStep: Step;
}

const steps: { key: Step; label: string }[] = [
  { key: 'upload', label: 'Upload PDF' },
  { key: 'clean', label: 'Clean PDF' },
  { key: 'crop', label: 'Crop Images' },
  { key: 'extract', label: 'Extract Questions' },
];

export function Stepper({ currentStep }: StepperProps) {
  const currentIndex = steps.findIndex((s) => s.key === currentStep);

  return (
    <div className="flex items-center justify-between">
      {steps.map((step, index) => {
        const isActive = index === currentIndex;
        const isCompleted = index < currentIndex;

        return (
          <div key={step.key} className="flex items-center flex-1">
            <div className="flex flex-col items-center flex-1">
              <div
                className={`w-10 h-10 rounded-full flex items-center justify-center font-semibold ${
                  isCompleted
                    ? 'bg-green-500 text-white'
                    : isActive
                    ? 'bg-blue-500 text-white'
                    : 'bg-gray-300 text-gray-600'
                }`}
              >
                {isCompleted ? '✓' : index + 1}
              </div>
              <div
                className={`mt-2 text-sm font-medium ${
                  isActive ? 'text-blue-600' : isCompleted ? 'text-green-600' : 'text-gray-500'
                }`}
              >
                {step.label}
              </div>
            </div>
            {index < steps.length - 1 && (
              <div
                className={`h-1 flex-1 mx-2 ${
                  isCompleted ? 'bg-green-500' : 'bg-gray-300'
                }`}
              />
            )}
          </div>
        );
      })}
    </div>
  );
}
