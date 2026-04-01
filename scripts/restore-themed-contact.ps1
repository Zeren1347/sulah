param()

$ErrorActionPreference = "Stop"

function Build-ContactPage {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )

    $content = Get-Content $SourcePath -Raw
    $start = $content.IndexOf("<article")
    $end = $content.IndexOf("</article>")

    if ($start -lt 0 -or $end -lt 0) {
        throw "Could not locate article block in $SourcePath"
    }

    $prefix = $content.Substring(0, $start)
    $suffix = $content.Substring($end + 10)

    $prefix = $prefix.Replace("About | SulahMitra | ODR", "Contact | SulahMitra")
    $prefix = $prefix.Replace("About | SulahMitra", "Contact | SulahMitra")
    $prefix = $prefix.Replace(
        'content="SulahMitra was founded with a simple yet powerful vision: to provide an accessible, effective alternative to traditional litigation for resolving disputes."',
        'content="Contact SulahMitra for mediation and ODR support."'
    )
    $prefix = $prefix.Replace('<link rel="canonical" href="/about/" />', '<link rel="canonical" href="/contact/" />')
    $prefix = $prefix.Replace('<meta property="og:url" content="/about/" />', '<meta property="og:url" content="/contact/" />')
    $prefix = $prefix.Replace('/about/#breadcrumb', '/contact/#breadcrumb')
    $prefix = $prefix.Replace('/about/#webpage', '/contact/#webpage')
    $prefix = $prefix.Replace('/about/#richSnippet', '/contact/#richSnippet')
    $prefix = $prefix.Replace('{"@id":"/about/","name":"About"}', '{"@id":"/contact/","name":"Contact"}')
    $prefix = $prefix.Replace('"url":"/about/","name":"Contact | SulahMitra"', '"url":"/contact/","name":"Contact | SulahMitra"')
    $prefix = $prefix.Replace('https%3A%2F%2Fsulahmitra.in%2Fabout%2F', 'https%3A%2F%2Fsulahmitra.in%2Fcontact%2F')
    $prefix = $prefix.Replace(
        "/wp-content/litespeed/css/b5abd26703fd7584c1472858eaa0a1c9.css?ver=ee1b4",
        "/wp-content/litespeed/css/42fb54e75d19bcc19e08681d13acb05b.css?ver=ee1b4"
    )

    $prefix = $prefix.Replace(
        '<link rel="apple-touch-icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-180x180.png" /><meta name="msapplication-TileImage" content="/wp-content/uploads/2025/04/cropped-favicon-2-270x270.png" /></head>',
        '<link rel="apple-touch-icon" href="/wp-content/uploads/2025/04/cropped-favicon-2-180x180.png" /><meta name="msapplication-TileImage" content="/wp-content/uploads/2025/04/cropped-favicon-2-270x270.png" /><link rel="stylesheet" href="/assets/local/contact-theme.css" /></head>'
    )

    $prefix = $prefix.Replace(
        'menu-item menu-item-type-post_type menu-item-object-page menu-item-103',
        'menu-item menu-item-type-post_type menu-item-object-page current-menu-item page_item page-item-100 current_page_item menu-item-103'
    )
    $prefix = $prefix.Replace(
        'menu-item menu-item-type-post_type menu-item-object-page current-menu-item page_item page-item-107 current_page_item menu-item-2490',
        'menu-item menu-item-type-post_type menu-item-object-page menu-item-2490'
    )
    $prefix = $prefix.Replace(
        '<a href="/contact/" class="menu-link">Contact</a>',
        '<a href="/contact/" aria-current="page" class="menu-link">Contact</a>'
    )
    $prefix = $prefix.Replace(
        '<a href="/about/" aria-current="page" class="menu-link">About</a>',
        '<a href="/about/" class="menu-link">About</a>'
    )
    $prefix = $prefix.Replace(
        "<body itemtype='https://schema.org/WebPage' itemscope='itemscope' class=""wp-singular page-template-default page page-id-107 wp-custom-logo wp-theme-astra ast-desktop ast-page-builder-template ast-no-sidebar astra-4.9.1 ast-single-post ast-replace-site-logo-transparent ast-inherit-site-logo-transparent ast-theme-transparent-header ast-hfb-header ast-full-width-primary-header"">",
        "<body itemtype='https://schema.org/WebPage' itemscope='itemscope' class=""wp-singular page-template-default page page-id-100 wp-custom-logo wp-theme-astra ast-desktop ast-page-builder-template ast-no-sidebar astra-4.9.1 ast-single-post ast-replace-site-logo-transparent ast-inherit-site-logo-transparent ast-theme-transparent-header ast-hfb-header ast-full-width-primary-header"">"
    )
    $prefix = $prefix.Replace(
        '"description":"SulahMitra was founded with a simple yet powerful vision: to provide an accessible, effective alternative to traditional litigation for resolving disputes."',
        '"description":"Contact SulahMitra for mediation and ODR support."'
    )
    $prefix = [regex]::Replace(
        $prefix,
        '<div class="ast-builder-layout-element ast-flex site-header-focus-item ast-header-html-1" data-section="section-hb-html-1">.*?</div></div></div></div></div></div>',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $article = @'
<article
class="post-100 page type-page status-publish ast-article-single" id="post-100" itemtype="https://schema.org/CreativeWork" itemscope="itemscope"><header class="entry-header ast-no-title ast-header-without-markup"></header><div class="entry-content clear"
data-ast-blocks-layout="true" itemprop="text"><section class="sm-contact-section alignfull"><div class="sm-contact-wrap"><div class="sm-contact-grid"><aside class="sm-contact-sidebar"><h2>Talk To Us</h2><div class="sm-contact-meta"><div class="sm-contact-meta-item"><span class="sm-contact-meta-icon" aria-hidden="true"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 7L12 13L20 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><rect x="3" y="5" width="18" height="14" rx="2" stroke="currentColor" stroke-width="1.8"/></svg></span><div class="sm-contact-meta-copy"><span class="sm-contact-meta-label">Email</span><a href="mailto:contact@sulahmitra.in">contact@sulahmitra.in</a></div></div><div class="sm-contact-meta-item"><span class="sm-contact-meta-icon" aria-hidden="true"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M22 16.92V19.92C22 20.47 21.55 20.92 21 20.92C11.61 20.92 4 13.31 4 3.92C4 3.37 4.45 2.92 5 2.92H8C8.55 2.92 9 3.37 9 3.92C9 5.38 9.24 6.79 9.68 8.11C9.82 8.53 9.71 8.99 9.39 9.31L7.6 11.1C9.02 13.98 11.34 16.3 14.22 17.72L16.01 15.93C16.33 15.61 16.79 15.5 17.21 15.64C18.53 16.08 19.94 16.32 21.4 16.32C21.73 16.32 22 16.59 22 16.92Z" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></span><div class="sm-contact-meta-copy"><span class="sm-contact-meta-label">Phone Number</span><a href="tel:+919471612930">9471612930</a></div></div></div><div class="sm-contact-social"><p class="sm-contact-social-title">Follow Us:</p><div class="sm-contact-social-links"><span class="sm-contact-social-link" aria-hidden="true"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3.5" y="3.5" width="17" height="17" rx="5" stroke="currentColor" stroke-width="1.8"/><circle cx="12" cy="12" r="4" stroke="currentColor" stroke-width="1.8"/><circle cx="17.5" cy="6.5" r="1" fill="currentColor"/></svg></span><span class="sm-contact-social-link" aria-hidden="true"><svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M6.94 8.5H3.56V20H6.94V8.5ZM5.25 3C4.17 3 3.5 3.71 3.5 4.64C3.5 5.55 4.15 6.28 5.21 6.28H5.23C6.34 6.28 7.02 5.55 7.02 4.64C7 3.71 6.34 3 5.25 3ZM20.5 12.73C20.5 9.2 18.61 7.56 16.08 7.56C14.04 7.56 13.13 8.68 12.62 9.47V8.5H9.25C9.29 9.14 9.25 20 9.25 20H12.62V13.58C12.62 13.24 12.64 12.9 12.75 12.66C13.02 11.98 13.64 11.27 14.66 11.27C15.99 11.27 16.53 12.29 16.53 13.79V20H19.9V13.4C19.9 13.05 19.89 12.69 19.83 12.38C19.95 12.51 20.5 12.73 20.5 12.73Z"/></svg></span><span class="sm-contact-social-link" aria-hidden="true"><svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M18.9 3H21L14.86 10.02L22 21H16.41L12.03 14.39L6.57 21H4.47L11.03 13.06L4.18 3H9.91L13.87 9.09L18.9 3ZM18.16 19.69H19.32L9.28 4.24H8.03L18.16 19.69Z"/></svg></span></div></div></aside><div class="sm-contact-panel"><h2>Get In Touch</h2><h3>Enter details for a callback</h3><form class="local-contact-form sm-contact-form" action="https://formspree.io/f/mdapoewa" method="POST" data-redirect="/thank-you.html"><input type="hidden" name="_subject" value="New SulahMitra Submission" /><input type="hidden" name="form_name" value="Contact Form" /><input type="text" name="_gotcha" class="sm-contact-gotcha" tabindex="-1" autocomplete="off" /><label class="sm-contact-field"><input class="sm-contact-input" type="text" name="name" placeholder="Your Name *" autocomplete="name" required /></label><label class="sm-contact-field sm-contact-phone"><span class="sm-contact-phone-prefix">+91</span><input class="sm-contact-input" type="tel" name="phone" placeholder="Phone Number *" autocomplete="tel-national" inputmode="tel" data-country-code="+91" required /></label><label class="sm-contact-field"><input class="sm-contact-input" type="email" name="email" placeholder="Email" autocomplete="email" required /></label><label class="sm-contact-field"><textarea class="sm-contact-textarea" name="message" placeholder="Message *" rows="6" required></textarea></label><div class="sm-contact-actions"><button type="submit" class="local-form-submit sm-contact-submit">SEND NOW</button></div><p class="local-form-status sm-contact-status" aria-live="polite"></p></form></div></div></div></section></div></article>
'@

    $suffix = $suffix.Replace(
        'class="menu-item menu-item-type-post_type menu-item-object-page current-menu-item page_item page-item-107 current_page_item menu-item-2490"',
        'class="menu-item menu-item-type-post_type menu-item-object-page menu-item-2490"'
    )
    $suffix = $suffix.Replace(
        '<a href="/about/" aria-current="page" class="menu-link">About</a>',
        '<a href="/about/" class="menu-link">About</a>'
    )

    if ($suffix -notmatch "/assets/local/local.js") {
        $suffix = $suffix.Replace("</body>", '<script src="/assets/local/local.js" defer></script></body>')
    }

    $result = $prefix + $article + $suffix
    [System.IO.File]::WriteAllText($DestinationPath, $result, [System.Text.UTF8Encoding]::new($false))
}

Build-ContactPage -SourcePath "about/index.html" -DestinationPath "contact/index.html"
Build-ContactPage -SourcePath "site/about/index.html" -DestinationPath "site/contact/index.html"
