param(
    [string]$OutputFolder = "site"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outputRoot = Join-Path $repoRoot $OutputFolder
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$copiedFiles = New-Object System.Collections.Generic.HashSet[string]
$queuedFiles = New-Object System.Collections.Generic.HashSet[string]
$processedFiles = New-Object System.Collections.Generic.HashSet[string]
$queue = New-Object System.Collections.Generic.Queue[string]
$formspreeEndpoint = "https://formspree.io/f/mdapoewa"
$thankYouPath = "/thank-you.html"

$englishFormMarkup = @"
<div class="local-contact-card">
  <form class="local-contact-form" action="$formspreeEndpoint" method="POST" data-redirect="$thankYouPath">
    <input type="hidden" name="_subject" value="New SulahMitra Submission">
    <input type="hidden" name="form_name" value="Contact Form">
    <input type="text" name="_gotcha" style="display:none" tabindex="-1" autocomplete="off">
    <div class="local-form-grid">
      <label class="local-form-field">
        <span>Full Name</span>
        <input type="text" name="name" autocomplete="name" required>
      </label>
      <label class="local-form-field">
        <span>Email Address</span>
        <input type="email" name="email" autocomplete="email" required>
      </label>
      <label class="local-form-field">
        <span>Phone Number</span>
        <div class="local-phone-field">
          <span class="local-phone-prefix">+91</span>
          <input type="tel" name="phone" autocomplete="tel-national" inputmode="tel" placeholder="98765 43210" data-country-code="+91">
        </div>
        <p class="local-form-help">Default country: India</p>
      </label>
      <label class="local-form-field">
        <span>Subject</span>
        <input type="text" name="subject">
      </label>
      <label class="local-form-field local-form-field--full">
        <span>Message</span>
        <textarea name="message" rows="6" required></textarea>
      </label>
    </div>
    <div class="local-form-actions">
      <button type="submit" class="local-form-submit">Send Message</button>
      <p class="local-form-note">Submitted securely through Formspree.</p>
      <p class="local-form-status" aria-live="polite"></p>
    </div>
  </form>
</div>
"@

$hindiFormMarkup = @"
<div class="local-contact-card">
  <form class="local-contact-form" action="$formspreeEndpoint" method="POST" data-redirect="$thankYouPath">
    <input type="hidden" name="_subject" value="New SulahMitra Submission">
    <input type="hidden" name="form_name" value="Hindi Contact Form">
    <input type="text" name="_gotcha" style="display:none" tabindex="-1" autocomplete="off">
    <div class="local-form-grid">
      <label class="local-form-field">
        <span>&#x092A;&#x0942;&#x0930;&#x093E; &#x0928;&#x093E;&#x092E;</span>
        <input type="text" name="name" autocomplete="name" required>
      </label>
      <label class="local-form-field">
        <span>&#x0908;&#x092E;&#x0947;&#x0932; &#x092A;&#x0924;&#x093E;</span>
        <input type="email" name="email" autocomplete="email" required>
      </label>
      <label class="local-form-field">
        <span>&#x092B;&#x093C;&#x094B;&#x0928; &#x0928;&#x0902;&#x092C;&#x0930;</span>
        <div class="local-phone-field">
          <span class="local-phone-prefix">+91</span>
          <input type="tel" name="phone" autocomplete="tel-national" inputmode="tel" placeholder="98765 43210" data-country-code="+91">
        </div>
        <p class="local-form-help">&#x0921;&#x093F;&#x092B;&#x093C;&#x0949;&#x0932;&#x094D;&#x091F; &#x0926;&#x0947;&#x0936;: &#x092D;&#x093E;&#x0930;&#x0924;</p>
      </label>
      <label class="local-form-field">
        <span>&#x0935;&#x093F;&#x0937;&#x092F;</span>
        <input type="text" name="subject">
      </label>
      <label class="local-form-field local-form-field--full">
        <span>&#x0938;&#x0902;&#x0926;&#x0947;&#x0936;</span>
        <textarea name="message" rows="6" required></textarea>
      </label>
    </div>
    <div class="local-form-actions">
      <button type="submit" class="local-form-submit">&#x092D;&#x0947;&#x091C;&#x0947;&#x0902;</button>
      <p class="local-form-note">Formspree &#x0915;&#x0947; &#x091C;&#x0930;&#x093F;&#x090F; &#x0938;&#x0941;&#x0930;&#x0915;&#x094D;&#x0937;&#x093F;&#x0924; &#x0930;&#x0942;&#x092A; &#x0938;&#x0947; &#x092D;&#x0947;&#x091C;&#x093E; &#x091C;&#x093E;&#x090F;&#x0917;&#x093E;.</p>
      <p class="local-form-status" aria-live="polite"></p>
    </div>
  </form>
</div>
"@

$registrationFormMarkup = @"
<div class="local-contact-card local-contact-card--registration">
  <form class="local-contact-form" action="$formspreeEndpoint" method="POST" data-redirect="$thankYouPath">
    <input type="hidden" name="_subject" value="New SulahMitra Submission">
    <input type="hidden" name="form_name" value="Registration Form">
    <input type="text" name="_gotcha" style="display:none" tabindex="-1" autocomplete="off">
    <div class="local-form-grid">
      <label class="local-form-field">
        <span>Full Name</span>
        <input type="text" name="name" autocomplete="name" required>
      </label>
      <label class="local-form-field">
        <span>Email Address</span>
        <input type="email" name="email" autocomplete="email" required>
      </label>
      <label class="local-form-field">
        <span>Phone Number</span>
        <div class="local-phone-field">
          <span class="local-phone-prefix">+91</span>
          <input type="tel" name="phone" autocomplete="tel-national" inputmode="tel" placeholder="98765 43210" data-country-code="+91">
        </div>
        <p class="local-form-help">Default country: India</p>
      </label>
      <label class="local-form-field">
        <span>City / Organization</span>
        <input type="text" name="organization">
      </label>
      <label class="local-form-field">
        <span>Case Type</span>
        <input type="text" name="case_type">
      </label>
      <label class="local-form-field">
        <span>Preferred Callback Time</span>
        <input type="text" name="callback_time">
      </label>
      <label class="local-form-field local-form-field--full">
        <span>Case Details</span>
        <textarea name="case_details" rows="7" required></textarea>
      </label>
    </div>
    <div class="local-form-actions">
      <button type="submit" class="local-form-submit">Submit Registration</button>
      <p class="local-form-note">Submitted securely through Formspree.</p>
      <p class="local-form-status" aria-live="polite"></p>
    </div>
  </form>
</div>
"@

$localCss = @"
.local-contact-form {
  display: block;
}

.local-contact-card {
  border: 1px solid rgba(12, 17, 43, 0.12);
  border-radius: 20px;
  background: #ffffff;
  box-shadow: 0 18px 48px rgba(12, 17, 43, 0.08);
  padding: 28px;
}

.local-form-grid {
  display: grid;
  gap: 18px;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.local-form-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.local-form-field span {
  font-weight: 600;
  color: #101828;
}

.local-form-field--full {
  grid-column: 1 / -1;
}

.local-contact-form input,
.local-contact-form textarea {
  width: 100%;
  border: 1px solid rgba(12, 17, 43, 0.16);
  border-radius: 14px;
  background: #ffffff;
  padding: 14px 16px;
  color: #101828;
}

.local-contact-form textarea {
  min-height: 180px;
  resize: vertical;
}

.local-phone-field {
  display: flex;
  align-items: stretch;
  border: 1px solid rgba(12, 17, 43, 0.16);
  border-radius: 14px;
  background: #ffffff;
  overflow: hidden;
}

.local-phone-prefix {
  display: inline-flex;
  align-items: center;
  padding: 0 16px;
  background: #f8fafc;
  border-right: 1px solid rgba(12, 17, 43, 0.12);
  color: #344054;
  font-weight: 700;
  white-space: nowrap;
}

.local-phone-field input {
  border: 0;
  border-radius: 0;
}

.local-phone-field input:focus {
  outline: none;
}

.local-form-help {
  margin: 0;
  color: #667085;
  font-size: 0.9rem;
}

.local-form-actions {
  display: grid;
  gap: 12px;
  margin-top: 22px;
}

.local-form-submit {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: fit-content;
  min-width: 220px;
  border: 0;
  border-radius: 999px;
  background: #111c44;
  color: #ffffff;
  cursor: pointer;
  font-weight: 700;
  padding: 14px 26px;
  transition: background-color 0.2s ease, transform 0.2s ease, opacity 0.2s ease;
}

.local-form-submit:hover {
  background: #0b1431;
  transform: translateY(-1px);
}

.local-form-submit:disabled {
  cursor: wait;
  opacity: 0.72;
  transform: none;
}

.local-form-note,
.local-form-status {
  margin: 0;
  color: #475467;
}

.local-form-status {
  color: #14532d;
  font-weight: 600;
}

.local-form-status--error {
  color: #b42318;
}

.local-form-gotcha {
  display: none !important;
}

.local-standalone-page {
  margin: 0;
  min-height: 100vh;
  background:
    radial-gradient(circle at top, rgba(17, 28, 68, 0.14), transparent 34%),
    linear-gradient(180deg, #f4f7fb 0%, #eef2f8 100%);
  color: #101828;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.local-standalone-shell {
  width: min(100%, 760px);
  margin: 0 auto;
  padding: 48px 20px;
}

.local-standalone-card {
  border: 1px solid rgba(12, 17, 43, 0.1);
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 26px 70px rgba(12, 17, 43, 0.12);
  padding: 28px;
}

.local-standalone-brand {
  display: inline-flex;
  margin-bottom: 18px;
}

.local-standalone-brand img {
  width: 132px;
  height: auto;
}

.local-standalone-kicker {
  margin: 0 0 10px;
  color: #475467;
  font-size: 0.92rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.local-standalone-card h1 {
  margin: 0 0 12px;
  color: #111c44;
  font-size: clamp(2rem, 4vw, 3rem);
  line-height: 1.05;
}

.local-standalone-intro,
.local-standalone-meta {
  margin: 0 0 20px;
  color: #475467;
  line-height: 1.6;
}

.local-standalone-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 22px;
}

.local-standalone-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 180px;
  border-radius: 999px;
  background: #111c44;
  color: #ffffff;
  font-weight: 700;
  padding: 14px 22px;
  text-decoration: none;
}

.local-standalone-link--secondary {
  background: #dbe4f0;
  color: #111c44;
}

@media (max-width: 768px) {
  .local-contact-card {
    padding: 22px;
  }

  .local-form-grid {
    grid-template-columns: 1fr;
  }

  .local-form-field--full {
    grid-column: auto;
  }

  .local-form-submit {
    width: 100%;
  }

  .local-standalone-card {
    padding: 22px;
  }

  .local-standalone-shell {
    padding: 28px 16px;
  }

  .local-standalone-actions,
  .local-standalone-link {
    width: 100%;
  }
}
"@

$localJs = @'
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
'@

function Get-StandaloneFormPageHtml {
    param(
        [string]$LanguageCode,
        [string]$PageTitle,
        [string]$HeadingHtml,
        [string]$IntroHtml,
        [string]$FormMarkup,
        [string]$MetaHtml = 'Prefer email? <a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a>',
        [string]$ActionsHtml = ''
    )

    return @"
<!DOCTYPE html>
<html lang="$LanguageCode">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$PageTitle</title>
  <link rel="icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-32x32.png" sizes="32x32">
  <link rel="icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-192x192.png" sizes="192x192">
  <link rel="apple-touch-icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-180x180.png">
  <link rel="stylesheet" href="/assets/local/local.css">
</head>
<body class="local-standalone-page">
  <main class="local-standalone-shell">
    <a class="local-standalone-brand" href="/" aria-label="SulahMitra home">
      <img src="/wp-content/uploads/2025/04/logo_png_with_text.png" alt="SulahMitra logo">
    </a>
    <section class="local-standalone-card">
      <p class="local-standalone-kicker">SulahMitra</p>
      <h1>$HeadingHtml</h1>
      <p class="local-standalone-intro">$IntroHtml</p>
      $FormMarkup
      <p class="local-standalone-meta">$MetaHtml</p>
      $ActionsHtml
    </section>
  </main>
  <script src="/assets/local/local.js" defer></script>
</body>
</html>
"@
}

$thankYouHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Thank You | SulahMitra</title>
  <link rel="icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-32x32.png" sizes="32x32">
  <link rel="icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-192x192.png" sizes="192x192">
  <link rel="apple-touch-icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-180x180.png">
  <link rel="stylesheet" href="/assets/local/local.css">
</head>
<body class="local-standalone-page">
  <main class="local-standalone-shell">
    <section class="local-standalone-card">
      <p class="local-standalone-kicker">Submission received</p>
      <h1>Thank you.</h1>
      <p class="local-standalone-intro">Your SulahMitra form has been sent successfully. We will review it and get back to you soon.</p>
      <div class="local-standalone-actions">
        <a class="local-standalone-link" href="/">Back to home</a>
        <a class="local-standalone-link local-standalone-link--secondary" href="/contact/">Send another message</a>
      </div>
    </section>
  </main>
</body>
</html>
"@

function Read-Utf8File {
    param([string]$FilePath)
    return [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
}

function Write-Utf8File {
    param(
        [string]$FilePath,
        [string]$Content
    )

    $directory = Split-Path -Parent $FilePath
    if ($directory) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    [System.IO.File]::WriteAllText($FilePath, $Content, $utf8NoBom)
}

function Add-ToQueue {
    param([string]$RelativePath)

    $normalized = $RelativePath.Replace("\", "/")
    if ($queuedFiles.Add($normalized)) {
        $queue.Enqueue($normalized)
    }
}

function Ensure-OutputFile {
    param([string]$RelativePath)

    $normalized = $RelativePath.Replace("\", "/")
    $outputFile = Join-Path $outputRoot $normalized

    if (Test-Path $outputFile) {
        Add-ToQueue -RelativePath $normalized
        return
    }

    $sourceFile = Join-Path $repoRoot $normalized
    if (-not (Test-Path $sourceFile)) {
        Write-Warning "Missing local dependency: $normalized"
        return
    }

    $destinationDir = Split-Path -Parent $outputFile
    if ($destinationDir) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }

    Copy-Item -Path $sourceFile -Destination $outputFile -Force
    $null = $copiedFiles.Add($normalized)

    if ($normalized -match '\.(html|css|js)$') {
        Add-ToQueue -RelativePath $normalized
    }
}

function Resolve-DependencyPath {
    param(
        [string]$CurrentRelativePath,
        [string]$RawReference
    )

    if ([string]::IsNullOrWhiteSpace($RawReference)) { return $null }

    $reference = $RawReference.Trim().Trim("'`"")
    if (
        $reference.StartsWith("data:") -or
        $reference.StartsWith("#") -or
        $reference.StartsWith("mailto:") -or
        $reference.StartsWith("javascript:") -or
        $reference.StartsWith("http://") -or
        $reference.StartsWith("https://") -or
        $reference.StartsWith("//")
    ) {
        return $null
    }

    $reference = $reference.Split("#")[0]
    $reference = $reference.Split("?")[0]

    if ([string]::IsNullOrWhiteSpace($reference)) { return $null }

    if ($reference.StartsWith("/")) {
        return $reference.TrimStart("/").Replace("\", "/")
    }

    $baseDirectory = Split-Path $CurrentRelativePath -Parent
    $combined = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $repoRoot $baseDirectory) $reference))

    if (-not $combined.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    return $combined.Substring($repoRoot.Length + 1).Replace("\", "/")
}

function Extract-Dependencies {
    param(
        [string]$CurrentRelativePath,
        [string]$Content
    )

    $references = New-Object System.Collections.Generic.List[string]
    $extension = [System.IO.Path]::GetExtension($CurrentRelativePath).ToLowerInvariant()

    if ($extension -eq ".html") {
        foreach ($match in [regex]::Matches($Content, '(?:src|href|data-src|poster)=["'']([^"'']+)["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $resolved = Resolve-DependencyPath -CurrentRelativePath $CurrentRelativePath -RawReference $match.Groups[1].Value
            if ($resolved) {
                $references.Add($resolved)
            }
        }

        foreach ($match in [regex]::Matches($Content, '(?:srcset|data-srcset)=["'']([^"'']+)["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $srcsetValues = $match.Groups[1].Value -split ','
            foreach ($entry in $srcsetValues) {
                $candidate = ($entry.Trim() -split '\s+')[0]
                $resolved = Resolve-DependencyPath -CurrentRelativePath $CurrentRelativePath -RawReference $candidate
                if ($resolved) {
                    $references.Add($resolved)
                }
            }
        }

        foreach ($match in [regex]::Matches($Content, '["'']((?:/|\./|\.\./)[^"'']+\.(?:avif|css|gif|ico|jpe?g|js|png|svg|webp|woff2?))(?:\?[^"'']*)?["'']', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $resolved = Resolve-DependencyPath -CurrentRelativePath $CurrentRelativePath -RawReference $match.Groups[1].Value
            if ($resolved) {
                $references.Add($resolved)
            }
        }
    }

    if ($extension -eq ".css") {
        foreach ($match in [regex]::Matches($Content, 'url\(([^)]+)\)', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            $resolved = Resolve-DependencyPath -CurrentRelativePath $CurrentRelativePath -RawReference $match.Groups[1].Value
            if ($resolved) {
                $references.Add($resolved)
            }
        }
    }

    return $references | Sort-Object -Unique
}

function Remove-MetadataNoise {
    param([string]$Html)

    $patterns = @(
        '<link rel="profile" href="https://gmpg\.org/xfn/11">',
        "<link rel='dns-prefetch' href='//fonts\.googleapis\.com' ?/?>",
        '<link rel="https://api\.w\.org/" href="/wp-json/" ?/?>',
        '<link rel="alternate" type="application/rss\+xml"[^>]+href="/feed/" ?/?>',
        '<link rel="alternate" type="application/rss\+xml"[^>]+href="/comments/feed/" ?/?>',
        '<link rel="alternate" type="application/rss\+xml"[^>]+href="/author/[^"]+/feed/" ?/?>',
        '<link rel="alternate" title="JSON" type="application/json" href="/wp-json/[^"]+" ?/?>',
        '<link rel="EditURI" type="application/rsd\+xml" title="RSD" href="/xmlrpc\.php\?rsd" ?/?>',
        "<link rel='shortlink' href='[^']*' ?/?>",
        '<link rel="alternate" title="oEmbed \(JSON\)" type="application/json\+oembed" href="/wp-json/oembed/[^"]+" ?/?>',
        '<link rel="alternate" title="oEmbed \(XML\)" type="text/xml\+oembed" href="/wp-json/oembed/[^"]+" ?/?>',
        '<meta name="generator" content="WordPress [^"]+" ?/?>',
        '<script data-cfasync="false" src="/cdn-cgi/scripts/5c5dd728/cloudflare-static/email-decode\.min\.js"></script>',
        '<script id="srfm-form-submit-js-extra" type="litespeed/javascript">.*?</script>',
        '<script type="litespeed/javascript" data-src="https://www\.google\.com/recaptcha/api\.js[^"]*" id="srfm-google-recaptchaV3-js"></script>',
        '<script[^>]+(?:src|data-src)="[^"]*sureforms[^"]*"[^>]*></script>',
        '<link[^>]+href="[^"]*sureforms[^"]*"[^>]*>',
        '<!-- Page optimized by LiteSpeed Cache.*$',
        '<!-- Page cached by LiteSpeed Cache.*$',
        '<!-- Guest Mode -->',
        '<!-- QUIC\.cloud UCSS in queue -->'
    )

    foreach ($pattern in $patterns) {
        $Html = [regex]::Replace(
            $Html,
            $pattern,
            "",
            [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::Multiline
        )
    }

    return $Html
}

function Inject-LocalAssets {
    param([string]$Html)

    if ($Html -notmatch '/assets/local/local\.css') {
        $Html = $Html -replace '</head>', '<link rel="stylesheet" href="/assets/local/local.css"></head>'
    }

    if ($Html -notmatch '/assets/local/local\.js') {
        $Html = $Html -replace '</body>', '<script src="/assets/local/local.js" defer></script></body>'
    }

    return $Html
}

function Replace-EmailProtection {
    param([string]$Html)

    return [regex]::Replace(
        $Html,
        '<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="[^"]+">\[email&#160;protected\]</a>',
        '<a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a>'
    )
}

function Replace-FormBlock {
    param(
        [string]$Html,
        [string]$ReplacementMarkup
    )

    return [regex]::Replace(
        $Html,
        '<div class="srfm-form-container.*?</form><div class="srfm-single-form.*?</div></div>',
        $ReplacementMarkup,
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
}

function Get-CssMatchingBraceIndex {
    param(
        [string]$Text,
        [int]$OpenIndex
    )

    $depth = 0
    $inSingleQuote = $false
    $inDoubleQuote = $false
    $inComment = $false

    for ($i = $OpenIndex; $i -lt $Text.Length; $i++) {
        $char = $Text[$i]
        $nextChar = if ($i + 1 -lt $Text.Length) { $Text[$i + 1] } else { [char]0 }

        if ($inComment) {
            if ($char -eq '*' -and $nextChar -eq '/') {
                $inComment = $false
                $i++
            }
            continue
        }

        if ($inSingleQuote) {
            if ($char -eq '\') {
                $i++
                continue
            }

            if ($char -eq "'") {
                $inSingleQuote = $false
            }
            continue
        }

        if ($inDoubleQuote) {
            if ($char -eq '\') {
                $i++
                continue
            }

            if ($char -eq '"') {
                $inDoubleQuote = $false
            }
            continue
        }

        if ($char -eq '/' -and $nextChar -eq '*') {
            $inComment = $true
            $i++
            continue
        }

        if ($char -eq "'") {
            $inSingleQuote = $true
            continue
        }

        if ($char -eq '"') {
            $inDoubleQuote = $true
            continue
        }

        if ($char -eq '{') {
            $depth++
            continue
        }

        if ($char -eq '}') {
            $depth--
            if ($depth -eq 0) {
                return $i
            }
        }
    }

    return -1
}

function Remove-SureFormsDeclarations {
    param([string]$Body)

    $Body = [regex]::Replace(
        $Body,
        '--srfm-[A-Za-z0-9_-]+\s*:\s*[^;{}]+;?',
        '',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    $Body = [regex]::Replace(
        $Body,
        '--iti-path-[A-Za-z0-9_-]+\s*:\s*url\([^)]*sureforms[^)]*\)\s*;?',
        '',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    return $Body
}

function Process-CssChunk {
    param([string]$Text)

    $builder = New-Object System.Text.StringBuilder
    $cursor = 0

    while ($cursor -lt $Text.Length) {
        $nextOpenBrace = $Text.IndexOf('{', $cursor)
        $nextSemicolon = $Text.IndexOf(';', $cursor)

        if ($nextOpenBrace -lt 0) {
            $tail = $Text.Substring($cursor)
            if ($tail -notmatch '(?i)srfm|sureforms') {
                [void]$builder.Append($tail)
            }
            break
        }

        if ($nextSemicolon -ge 0 -and $nextSemicolon -lt $nextOpenBrace) {
            $statement = $Text.Substring($cursor, $nextSemicolon - $cursor + 1)
            if ($statement -notmatch '(?i)srfm|sureforms') {
                [void]$builder.Append($statement)
            }
            $cursor = $nextSemicolon + 1
            continue
        }

        $prelude = $Text.Substring($cursor, $nextOpenBrace - $cursor)
        $closeBrace = Get-CssMatchingBraceIndex -Text $Text -OpenIndex $nextOpenBrace

        if ($closeBrace -lt 0) {
            break
        }

        $body = $Text.Substring($nextOpenBrace + 1, $closeBrace - $nextOpenBrace - 1)
        $cursor = $closeBrace + 1

        if ($prelude -match '^\s*@(?:media|supports|container|layer|document)\b') {
            $processedBody = Process-CssChunk -Text $body
            if ($processedBody -match '\S') {
                [void]$builder.Append($prelude).Append('{').Append($processedBody).Append('}')
            }
            continue
        }

        if ($prelude -match '^\s*@(?:-webkit-)?keyframes\b') {
            if ($prelude -notmatch '(?i)srfm|sureforms') {
                [void]$builder.Append($prelude).Append('{').Append($body).Append('}')
            }
            continue
        }

        if ($prelude -match '(?i):root') {
            $cleanedBody = Remove-SureFormsDeclarations -Body $body
            if (
                $cleanedBody -match '[A-Za-z0-9_-]+\s*:' -and
                $cleanedBody -notmatch '(?i)(?:var\(--srfm-|/plugins/sureforms/|sureforms/assets|srfm-)'
            ) {
                [void]$builder.Append($prelude).Append('{').Append($cleanedBody).Append('}')
            }
            continue
        }

        if (
            $prelude -match '(?i)srfm|sureforms' -or
            $body -match '(?i)(?:--srfm-|var\(--srfm-|/plugins/sureforms/|sureforms/assets|srfm-)'
        ) {
            continue
        }

        [void]$builder.Append($prelude).Append('{').Append($body).Append('}')
    }

    return $builder.ToString()
}

function Remove-SureFormsCssNoise {
    param([string]$Content)

    if ($Content -notmatch '(?i)srfm|sureforms') {
        return $Content
    }

    $Content = Process-CssChunk -Text $Content
    $aggressivePatterns = @(
        '(?s)([{}]|^)\s*[^{}]*(?:srfm|sureforms_form)[^{}]*\{[^{}]*\}',
        '(?s)([{}]|^)\s*[^{}]*\{[^{}]*(?:var\(--srfm-|/plugins/sureforms/|sureforms/assets)[^{}]*\}'
    )

    foreach ($pattern in $aggressivePatterns) {
        do {
            $previous = $Content
            $Content = [regex]::Replace(
                $Content,
                $pattern,
                '$1',
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
            )
        } while ($Content -ne $previous)
    }

    $Content = [regex]::Replace($Content, ':root\{\s*\}', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $Content = [regex]::Replace($Content, '@(?:media|supports|container|layer|document)[^{]+\{\s*\}', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    return $Content
}

function Transform-StaticTextAsset {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $extension = [System.IO.Path]::GetExtension($RelativePath).ToLowerInvariant()

    switch ($extension) {
        ".css" {
            $Content = $Content -replace 'https://sulahmitra\.in/wp-content/', '/wp-content/'
            $Content = $Content -replace '//sulahmitra\.in/wp-content/', '/wp-content/'
            $Content = Remove-SureFormsCssNoise -Content $Content
        }
        ".js" {
            $Content = $Content -replace 'https://sulahmitra\.in/wp-json/', '/wp-json/'
            $Content = $Content -replace 'https://sulahmitra\.in/wp-admin/admin-ajax\.php\?action=rest-nonce', '/wp-admin/admin-ajax.php?action=rest-nonce'
        }
        ".xml" {
            $Content = $Content -replace 'href="//sulahmitra\.in/main-sitemap\.xsl"', 'href="/main-sitemap.xsl"'
            $Content = $Content -replace 'https://sulahmitra\.in/wp-content/', '/wp-content/'
            $Content = $Content -replace 'https://sulahmitra\.in/', '/'
        }
        ".xsl" {
            $Content = $Content -replace 'https://sulahmitra\.in/', '/'
            $Content = $Content -replace '//sulahmitra\.in/', '/'
        }
        ".txt" {
            $Content = $Content -replace 'https://sulahmitra\.in/sitemap_index\.xml', '/sitemap_index.xml'
            $Content = $Content -replace '(?m)^Allow: /wp-admin/admin-ajax\.php\r?\n?', ''
        }
    }

    return $Content
}

function Transform-Html {
    param(
        [string]$RelativePath,
        [string]$Html
    )

    $Html = Remove-MetadataNoise -Html $Html
    $Html = Replace-EmailProtection -Html $Html
    $Html = $Html -replace 'href="contact/"', 'href="/contact/"'
    $Html = $Html -replace 'href="contact"', 'href="/contact/"'
    $Html = [regex]::Replace(
        $Html,
        '<a href="https://sureforms\.com/" class="srfm-branding" target="_blank">.*?</a>',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $Html = [regex]::Replace(
        $Html,
        '<script[^>]+(?:src|data-src)="/wp-content/litespeed/js/(?:2ed85ad8fd63ddbe065f19bf533708d5|8e25279584649bb498038e0c39602a2e)\.js[^"]*"[^>]*></script>',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    switch ($RelativePath) {
        "contact/index.html" {
            $Html = Get-StandaloneFormPageHtml `
                -LanguageCode "en" `
                -PageTitle "Contact | SulahMitra" `
                -HeadingHtml "Contact SulahMitra" `
                -IntroHtml "Use this secure static form to reach SulahMitra directly. The form no longer depends on WordPress, Google authentication, or any plugin backend." `
                -FormMarkup $englishFormMarkup `
                -MetaHtml 'Prefer email? <a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a>' `
                -ActionsHtml '<div class="local-standalone-actions"><a class="local-standalone-link local-standalone-link--secondary" href="/registration/">Open registration form</a></div>'
        }
        "hindi/contact/index.html" {
            $Html = Get-StandaloneFormPageHtml `
                -LanguageCode "hi" `
                -PageTitle "Contact Hindi | SulahMitra" `
                -HeadingHtml "&#x0938;&#x0902;&#x092A;&#x0930;&#x094D;&#x0915; &#x0915;&#x0930;&#x0947;&#x0902;" `
                -IntroHtml "&#x092F;&#x0939; &#x0938;&#x0941;&#x0930;&#x0915;&#x094D;&#x0937;&#x093F;&#x0924; &#x0938;&#x094D;&#x0925;&#x093F;&#x0930; &#x092B;&#x093C;&#x0949;&#x0930;&#x094D;&#x092E; SulahMitra &#x0915;&#x094B; &#x0938;&#x0940;&#x0927;&#x0947; &#x0938;&#x0902;&#x0926;&#x0947;&#x0936; &#x092D;&#x0947;&#x091C;&#x0924;&#x093E; &#x0939;&#x0948;। &#x0905;&#x092C; &#x092F;&#x0939; WordPress, Google &#x0905;&#x0925;&#x0947;&#x0902;&#x091F;&#x093F;&#x0915;&#x0947;&#x0936;&#x0928; &#x092F;&#x093E; plugin backend &#x092A;&#x0930; &#x0928;&#x093F;&#x0930;&#x094D;&#x092D;&#x0930; &#x0928;&#x0939;&#x0940;&#x0902; &#x0939;&#x0948;&#x0964" `
                -FormMarkup $hindiFormMarkup `
                -MetaHtml '&#x0908;&#x092E;&#x0947;&#x0932; &#x0915;&#x0930;&#x0928;&#x093E; &#x0939;&#x0948;? <a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a>' `
                -ActionsHtml '<div class="local-standalone-actions"><a class="local-standalone-link local-standalone-link--secondary" href="/registration/">Registration form</a></div>'
        }
        "form/simple-contact-form/index.html" {
            $Html = Get-StandaloneFormPageHtml `
                -LanguageCode "en" `
                -PageTitle "Simple Contact Form | SulahMitra" `
                -HeadingHtml "Contact SulahMitra" `
                -IntroHtml "Use this secure static form to send your enquiry directly to SulahMitra." `
                -FormMarkup $englishFormMarkup
        }
        "form/simple-contact-form-hindi/index.html" {
            $Html = Get-StandaloneFormPageHtml `
                -LanguageCode "hi" `
                -PageTitle "Hindi Contact Form | SulahMitra" `
                -HeadingHtml "&#x0938;&#x0902;&#x092A;&#x0930;&#x094D;&#x0915; &#x0915;&#x0930;&#x0947;&#x0902;" `
                -IntroHtml "&#x0907;&#x0938; &#x0938;&#x0941;&#x0930;&#x0915;&#x094D;&#x0937;&#x093F;&#x0924; &#x0938;&#x094D;&#x0925;&#x093F;&#x0930; &#x092B;&#x093C;&#x0949;&#x0930;&#x094D;&#x092E; &#x0915;&#x0947; &#x091C;&#x0930;&#x093F;&#x090F; &#x0905;&#x092A;&#x0928;&#x093E; &#x0938;&#x0902;&#x0926;&#x0947;&#x0936; SulahMitra &#x0915;&#x094B; &#x092D;&#x0947;&#x091C;&#x0947;&#x0902;." `
                -FormMarkup $hindiFormMarkup
        }
        "registration/index.html" {
            $Html = Get-StandaloneFormPageHtml `
                -LanguageCode "en" `
                -PageTitle "Registration Form | SulahMitra" `
                -HeadingHtml "Registration Form" `
                -IntroHtml "Share your dispute details securely with SulahMitra. This form now submits directly to Formspree without WordPress, Google authentication, or plugin handlers." `
                -FormMarkup $registrationFormMarkup `
                -MetaHtml 'Need help before submitting? <a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a>' `
                -ActionsHtml '<div class="local-standalone-actions"><a class="local-standalone-link local-standalone-link--secondary" href="/contact/">Back to contact</a></div>'
        }
    }

    return $Html
}

if (Test-Path $outputRoot) {
    Remove-Item -Recurse -Force $outputRoot
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$pageFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "index.html" |
    Where-Object {
        $_.FullName -notlike "$outputRoot*" -and
        $_.FullName -notmatch '\\wp-content\\' -and
        $_.FullName -notmatch '\\wp-includes\\' -and
        $_.FullName -notmatch '\\scripts\\'
    } |
    Sort-Object FullName

$rootFiles = Get-ChildItem -Path $repoRoot -File |
    Where-Object { $_.Name -match '^(index\.html|main-sitemap\.xsl|page-sitemap\.xml|robots\.txt|sitemap\.xml|sitemap_index\.xml)$' }

foreach ($rootFile in $rootFiles) {
    $relativePath = $rootFile.FullName.Substring($repoRoot.Length + 1).Replace("\", "/")
    $destination = Join-Path $outputRoot $relativePath
    $destinationDir = Split-Path -Parent $destination
    if ($destinationDir) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }
    Copy-Item -Path $rootFile.FullName -Destination $destination -Force
}

foreach ($pageFile in $pageFiles) {
    $relativePath = $pageFile.FullName.Substring($repoRoot.Length + 1).Replace("\", "/")
    $destination = Join-Path $outputRoot $relativePath
    $destinationDir = Split-Path -Parent $destination
    if ($destinationDir) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }
    Copy-Item -Path $pageFile.FullName -Destination $destination -Force
}

Get-ChildItem -Path $outputRoot -File |
    Where-Object { $_.Extension -match '^\.(xml|xsl|txt)$' } |
    ForEach-Object {
        $relativePath = $_.FullName.Substring($outputRoot.Length + 1).Replace("\", "/")
        $content = Read-Utf8File -FilePath $_.FullName
        $transformed = Transform-StaticTextAsset -RelativePath $relativePath -Content $content
        Write-Utf8File -FilePath $_.FullName -Content $transformed
    }

Write-Utf8File -FilePath (Join-Path $outputRoot "assets/local/local.css") -Content $localCss
Write-Utf8File -FilePath (Join-Path $outputRoot "assets/local/local.js") -Content $localJs
Write-Utf8File -FilePath (Join-Path $outputRoot "thank-you.html") -Content $thankYouHtml
Copy-Item -Path (Join-Path $repoRoot "assets/local/contact-theme.css") -Destination (Join-Path $outputRoot "assets/local/contact-theme.css") -Force

$outputHtmlFiles = Get-ChildItem -Path $outputRoot -Recurse -Filter "index.html" | Sort-Object FullName

foreach ($outputHtmlFile in $outputHtmlFiles) {
    $relativePath = $outputHtmlFile.FullName.Substring($outputRoot.Length + 1).Replace("\", "/")
    $html = Read-Utf8File -FilePath $outputHtmlFile.FullName
    $transformed = Transform-Html -RelativePath $relativePath -Html $html
    Write-Utf8File -FilePath $outputHtmlFile.FullName -Content $transformed
}

Add-ToQueue -RelativePath "assets/local/local.css"
Add-ToQueue -RelativePath "assets/local/local.js"
Add-ToQueue -RelativePath "assets/local/contact-theme.css"
Add-ToQueue -RelativePath "thank-you.html"

foreach ($outputHtmlFile in $outputHtmlFiles) {
    $relativePath = $outputHtmlFile.FullName.Substring($outputRoot.Length + 1).Replace("\", "/")
    Add-ToQueue -RelativePath $relativePath
}

while ($queue.Count -gt 0) {
    $currentRelativePath = $queue.Dequeue()

    if (-not $processedFiles.Add($currentRelativePath)) {
        continue
    }

    $outputFile = Join-Path $outputRoot $currentRelativePath
    if (-not (Test-Path $outputFile)) {
        Ensure-OutputFile -RelativePath $currentRelativePath
        continue
    }

    if ($currentRelativePath -notmatch '\.(html|css|js)$') {
        continue
    }

    $content = Read-Utf8File -FilePath $outputFile
    $transformedContent = Transform-StaticTextAsset -RelativePath $currentRelativePath -Content $content
    if ($transformedContent -ne $content) {
        Write-Utf8File -FilePath $outputFile -Content $transformedContent
        $content = $transformedContent
    }
    $dependencies = Extract-Dependencies -CurrentRelativePath $currentRelativePath -Content $content

    foreach ($dependency in $dependencies) {
        Ensure-OutputFile -RelativePath $dependency
    }
}

& (Join-Path $PSScriptRoot "restore-themed-contact.ps1")

Write-Host "Clean static bundle created at: $outputRoot"
