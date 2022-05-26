/**
 * Reduces one or more errors into a string[] of error messages.
 * @author Sachet Khanal (Deloitte)
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 */
const reduceErrors = (errors) => {
  if (!Array.isArray(errors)) {
    errors = [errors];
  }

  return (
    errors
    // Remove null/undefined items
    .filter((error) => !!error)
    // Extract an error message
    .map((error) => {
      // UI API read errors
      if (Array.isArray(error.body)) {
        return error.body.map((e) => e.message);
      }
      // UI API DML, Apex and network errors
      else if (error.body && typeof error.body.message === 'string') {
        return error.body.message;
      }
      // JS errors
      else if (typeof error.message === 'string') {
        return error.message;
      }
      else if (typeof error === 'string') {
        return error;
      }
      // Unknown error shape so try HTTP status text
      return error.statusText;
    })
    // Flatten
    .reduce((prev, curr) => prev.concat(curr), [])
    // Remove empty strings
    .filter((message) => !!message)
  );
}

const DATETIME_TYPE_ATTRIBUTE = {
  day: 'numeric',
  month: 'short',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit',
  second: '2-digit',
  hour12: true
}

const getTodaysDate = () => {
  let dt = new Date();
  dt.setHours(0, 0, 0, 0);
  return dt.toISOString()
    .split('T')[0];
}

export { reduceErrors, DATETIME_TYPE_ATTRIBUTE, getTodaysDate }