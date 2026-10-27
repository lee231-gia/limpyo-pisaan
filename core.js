export function validateReport(data) {
  const errors = {};
  if (!data.type?.trim()) errors.type = 'Choose an issue type.';
  if (!data.location?.trim()) errors.location = 'Enter a location or nearby landmark.';
  if (!data.description?.trim()) errors.description = 'Describe the waste-related concern.';
  return errors;
}
export function validateAccount(data) {
  const errors = {};
  if (!data.name?.trim()) errors.name = 'Enter your full name.';
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email || '')) errors.email = 'Enter a valid email, like name@example.com.';
  if ((data.password || '').length < 8) errors.password = 'Use at least 8 characters.';
  if (!data.confirm) errors.confirm = 'Please confirm your password.';
  else if (data.confirm !== data.password) errors.confirm = 'Passwords do not match. Please try again.';
  return errors;
}
export function nextReference(reports) {
  const n = Math.max(0, ...reports.map(r => Number(r.id.split('-').at(-1)) || 0)) + 1;
  return `DEMO-LP-${String(n).padStart(3, '0')}`;
}
