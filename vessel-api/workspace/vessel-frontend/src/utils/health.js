export function getHealth() {
  return {
    image: import.meta.env.VITE_IMAGE_NAME || 'vessel-preview',
    version: import.meta.env.VITE_APP_VERSION || 'dev',
  }
}
