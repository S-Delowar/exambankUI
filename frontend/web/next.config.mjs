/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // LAN access (uncomment to allow requests from other devices):
  // allowedDevOrigins: ["192.168.0.103"],
  // Expose the backend URL at build-time. Override per env with
  // NEXT_PUBLIC_API_BASE_URL=https://api.example.com in .env.local.
  env: {
    NEXT_PUBLIC_API_BASE_URL:
      process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000",
  },
};
export default nextConfig;



// /** @type {import('next').NextConfig} */
// const nextConfig = {
//   reactStrictMode: true,
//   // Required for Server Actions to work over LAN
//   experimental: {
//     serverActions: {
//       allowedOrigins: ["192.168.0.101:3000", "localhost:3000"],
//     },
//   },
//   env: {
//     NEXT_PUBLIC_API_BASE_URL:
//       process.env.NEXT_PUBLIC_API_BASE_URL || "http://192.168.0.101:8000",
//   },
// };
// export default nextConfig;