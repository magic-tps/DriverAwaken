import type { NextConfig } from 'next';

const config: NextConfig = {
  output: 'export',
  basePath: process.env.GITHUB_PAGES === 'true' ? '/DriverAwaken' : '',
  trailingSlash: true,
  poweredByHeader: false,
  images: { unoptimized: true },
};
export default config;
