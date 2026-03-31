function normalizePhoneInputs(form) {
  form.querySelectorAll('input[type="tel"][data-country-code]').forEach((input) => {
    const rawValue = input.value.trim();

    if (!rawValue) {
      return;
    }

    if (rawValue.startsWith('+')) {
      input.value = rawValue.replace(/\s+/g, ' ').trim();
      return;
    }

    const digitsOnly = rawValue.replace(/[^0-9]/g, '');
    if (!digitsOnly) {
      input.value = '';
      return;
    }

    input.value = `${input.dataset.countryCode} ${digitsOnly}`;
  });
}

document.querySelectorAll('.local-contact-form').forEach((form) => {
  if (!window.fetch || !window.FormData) {
    return;
  }

  form.addEventListener('submit', async (event) => {
    event.preventDefault();

    const status = form.querySelector('.local-form-status');
    const submitButton = form.querySelector('.local-form-submit');
    const redirectTarget = form.dataset.redirect || '/thank-you.html';
    const originalButtonText = submitButton ? submitButton.textContent : '';

    normalizePhoneInputs(form);
    const formData = new FormData(form);

    if (status) {
      status.classList.remove('local-form-status--error');
      status.textContent = 'Submitting...';
    }

    if (submitButton) {
      submitButton.disabled = true;
      submitButton.textContent = 'Submitting...';
    }

    try {
      const response = await fetch(form.action, {
        method: form.method || 'POST',
        headers: {
          Accept: 'application/json'
        },
        body: formData
      });

      if (!response.ok) {
        let message = 'Something went wrong. Please try again.';

        try {
          const data = await response.json();
          if (data && Array.isArray(data.errors) && data.errors.length > 0) {
            message = data.errors.map((item) => item.message).join(' ');
          }
        } catch (error) {
        }

        throw new Error(message);
      }

      form.reset();

      if (status) {
        status.textContent = 'Thanks! Redirecting...';
      }

      window.setTimeout(() => {
        window.location.href = redirectTarget;
      }, 1000);
    } catch (error) {
      if (status) {
        status.classList.add('local-form-status--error');
        status.textContent = error && error.message ? error.message : 'Something went wrong. Please try again.';
      }

      if (submitButton) {
        submitButton.disabled = false;
        submitButton.textContent = originalButtonText;
      }
    }
  });
});