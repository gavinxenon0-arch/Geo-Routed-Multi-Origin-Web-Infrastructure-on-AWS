#!/bin/bash
set -Eeuo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

REGION_LABEL="US Barrier Node"
PAGE_TITLE="Cursed Web Node"
PAGE_SUBTITLE="This EC2 instance is serving traffic behind an Application Load Balancer."
BADGE_TEXT="CLOUDFRONT • ALB • EC2"
TECHNIQUE_NAME="Cursed Technique: Geo Routing"

yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

BASE_URL="http://169.254.169.254/latest"
TOKEN=""

get_token() {
  curl -fsS -m 3 -X PUT "${BASE_URL}/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" || true
}

get_meta() {
  local path="$1"
  if [[ -n "${TOKEN}" ]]; then
    curl -fsS -m 3 -H "X-aws-ec2-metadata-token: ${TOKEN}" \
      "${BASE_URL}/meta-data/${path}" || true
  else
    echo ""
  fi
}

TOKEN="$(get_token)"

HOST_NAME="$(hostname -f 2>/dev/null || hostname)"
INSTANCE_ID="$(get_meta "instance-id")"
LOCAL_IP="$(get_meta "local-ipv4")"
AZ="$(get_meta "placement/availability-zone")"

INSTANCE_ID="${INSTANCE_ID:-unavailable}"
LOCAL_IP="${LOCAL_IP:-unavailable}"
AZ="${AZ:-unavailable}"

cat > /var/www/html/health <<'EOF'
ok
EOF

cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${PAGE_TITLE}</title>
  <style>
    :root {
      --bg-1: #03040a;
      --bg-2: #0a0f1d;
      --bg-3: #140816;
      --panel: rgba(10, 14, 28, 0.82);
      --panel-2: rgba(20, 10, 26, 0.78);
      --tile: rgba(255, 255, 255, 0.03);
      --text: #f2f5ff;
      --muted: #9ea7c7;
      --line: rgba(255,255,255,0.08);
      --red: #ff4d6d;
      --red-soft: rgba(255, 77, 109, 0.20);
      --violet: #8f5bff;
      --violet-soft: rgba(143, 91, 255, 0.22);
      --cyan: #70f0ff;
      --cyan-soft: rgba(112, 240, 255, 0.18);
      --green: #7dffb2;
      --shadow: rgba(0,0,0,0.50);
    }

    * { box-sizing: border-box; }

    html, body {
      margin: 0;
      min-height: 100%;
      font-family: Arial, Helvetica, sans-serif;
      color: var(--text);
      background:
        radial-gradient(circle at 15% 20%, var(--red-soft), transparent 24%),
        radial-gradient(circle at 82% 24%, var(--violet-soft), transparent 24%),
        radial-gradient(circle at 50% 80%, var(--cyan-soft), transparent 28%),
        linear-gradient(135deg, var(--bg-1), var(--bg-2) 45%, var(--bg-3));
      overflow-x: hidden;
    }

    body {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 28px;
      position: relative;
    }

    body::before {
      content: "";
      position: fixed;
      inset: 0;
      background:
        linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
      background-size: 34px 34px;
      mask-image: radial-gradient(circle at center, black 30%, transparent 85%);
      opacity: 0.12;
      pointer-events: none;
    }

    .aura-ring {
      position: fixed;
      width: 520px;
      height: 520px;
      border-radius: 50%;
      border: 1px solid rgba(255,255,255,0.05);
      box-shadow:
        0 0 80px var(--violet-soft),
        0 0 160px rgba(255, 77, 109, 0.08),
        inset 0 0 40px rgba(112,240,255,0.04);
      filter: blur(0.2px);
      opacity: 0.55;
      pointer-events: none;
      animation: pulse 7s ease-in-out infinite;
    }

    .shell {
      width: 100%;
      max-width: 980px;
      display: flex;
      justify-content: center;
      position: relative;
      z-index: 1;
    }

    .card {
      width: 100%;
      max-width: 720px;
      background:
        linear-gradient(180deg, rgba(255,255,255,0.03), rgba(255,255,255,0.01)),
        linear-gradient(135deg, var(--panel), var(--panel-2));
      border: 1px solid var(--line);
      border-radius: 24px;
      padding: 24px 24px 20px;
      box-shadow:
        0 30px 80px var(--shadow),
        0 0 40px rgba(143, 91, 255, 0.10),
        0 0 30px rgba(255, 77, 109, 0.08);
      backdrop-filter: blur(8px);
      position: relative;
      overflow: hidden;
    }

    .card::before {
      content: "";
      position: absolute;
      inset: 0;
      background:
        radial-gradient(circle at top left, rgba(255,77,109,0.08), transparent 22%),
        radial-gradient(circle at bottom right, rgba(112,240,255,0.08), transparent 24%);
      pointer-events: none;
    }

    .sigil {
      position: absolute;
      right: -30px;
      top: -30px;
      width: 170px;
      height: 170px;
      border-radius: 50%;
      border: 1px solid rgba(112,240,255,0.10);
      box-shadow:
        0 0 24px rgba(112,240,255,0.10),
        inset 0 0 18px rgba(143,91,255,0.08);
      opacity: 0.35;
      transform: rotate(18deg);
    }

    .sigil::before,
    .sigil::after {
      content: "";
      position: absolute;
      inset: 18px;
      border-radius: 50%;
      border: 1px solid rgba(255,255,255,0.07);
    }

    .sigil::after {
      inset: 38px;
      border-color: rgba(255,77,109,0.14);
    }

    .top {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 14px;
      margin-bottom: 18px;
      position: relative;
      z-index: 1;
    }

    .badge {
      display: inline-flex;
      align-items: center;
      padding: 8px 14px;
      border-radius: 999px;
      background: rgba(143, 91, 255, 0.14);
      border: 1px solid rgba(143, 91, 255, 0.22);
      color: #d5c6ff;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.10em;
      text-transform: uppercase;
    }

    .healthy {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      color: var(--green);
      font-size: 13px;
      font-weight: 700;
    }

    .healthy-dot {
      width: 9px;
      height: 9px;
      border-radius: 50%;
      background: var(--green);
      box-shadow: 0 0 14px var(--green);
    }

    h1 {
      margin: 10px 0 10px;
      font-size: 34px;
      line-height: 1.08;
      letter-spacing: -0.03em;
      position: relative;
      z-index: 1;
    }

    .subtitle {
      margin: 0 0 20px;
      color: var(--muted);
      font-size: 15px;
      line-height: 1.6;
      position: relative;
      z-index: 1;
      max-width: 620px;
    }

    .technique {
      display: inline-block;
      margin-bottom: 14px;
      padding: 9px 12px;
      border-radius: 12px;
      background: rgba(255, 77, 109, 0.08);
      border: 1px solid rgba(255, 77, 109, 0.16);
      color: #ffb8c6;
      font-size: 13px;
      font-weight: 700;
      position: relative;
      z-index: 1;
    }

    .hero {
      background:
        linear-gradient(180deg, rgba(40, 19, 46, 0.78), rgba(18, 23, 48, 0.90));
      border: 1px solid rgba(255,255,255,0.07);
      border-radius: 18px;
      padding: 18px 18px 16px;
      margin-bottom: 16px;
      position: relative;
      overflow: hidden;
      z-index: 1;
    }

    .hero::before {
      content: "";
      position: absolute;
      inset: 0;
      background:
        linear-gradient(90deg, rgba(255,77,109,0.08), transparent 35%, rgba(112,240,255,0.06));
      pointer-events: none;
    }

    .hero-title {
      font-size: 20px;
      font-weight: 800;
      margin-bottom: 8px;
      position: relative;
      z-index: 1;
    }

    .hero-text {
      color: var(--muted);
      font-size: 14px;
      line-height: 1.6;
      position: relative;
      z-index: 1;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 14px;
      position: relative;
      z-index: 1;
    }

    .tile {
      background: var(--tile);
      border: 1px solid rgba(255,255,255,0.07);
      border-radius: 16px;
      padding: 16px;
      min-height: 96px;
      box-shadow: inset 0 0 0 1px rgba(255,255,255,0.01);
    }

    .label {
      color: #9aa2c0;
      font-size: 10px;
      font-weight: 800;
      letter-spacing: 0.14em;
      text-transform: uppercase;
      margin-bottom: 10px;
    }

    .value {
      font-size: 16px;
      font-weight: 800;
      line-height: 1.45;
      word-break: break-word;
      color: #f4f7ff;
    }

    .footer {
      margin-top: 18px;
      padding-top: 16px;
      border-top: 1px solid rgba(255,255,255,0.06);
      color: #97a3c5;
      font-size: 12px;
      line-height: 1.65;
      position: relative;
      z-index: 1;
    }

    .footer strong {
      color: #ffffff;
    }

    .kanji-strip {
      margin-top: 12px;
      color: rgba(255,255,255,0.12);
      font-size: 11px;
      letter-spacing: 0.30em;
      text-transform: uppercase;
      white-space: nowrap;
      overflow: hidden;
    }

    @keyframes pulse {
      0%, 100% { transform: scale(1); opacity: 0.50; }
      50% { transform: scale(1.04); opacity: 0.68; }
    }

    @media (max-width: 760px) {
      .grid {
        grid-template-columns: 1fr;
      }

      h1 {
        font-size: 28px;
      }

      .top {
        align-items: flex-start;
        flex-direction: column;
      }

      .card {
        padding: 20px 20px 18px;
      }
    }
  </style>
</head>
<body>
  <div class="aura-ring"></div>

  <div class="shell">
    <div class="card">
      <div class="sigil"></div>

      <div class="top">
        <div class="badge">${BADGE_TEXT}</div>
        <div class="healthy"><span class="healthy-dot"></span> Healthy</div>
      </div>

      <div class="technique">${TECHNIQUE_NAME}</div>

      <h1>${PAGE_TITLE}</h1>
      <p class="subtitle">${PAGE_SUBTITLE}</p>

      <div class="hero">
        <div class="hero-title">${REGION_LABEL}</div>
        <div class="hero-text">
          Active backend responding successfully. This node is prepared to receive requests,
          maintain barrier stability, and confirm which origin CloudFront routed the viewer to.
        </div>
      </div>

      <div class="grid">
        <div class="tile">
          <div class="label">Hostname</div>
          <div class="value">${HOST_NAME}</div>
        </div>

        <div class="tile">
          <div class="label">Instance ID</div>
          <div class="value">${INSTANCE_ID}</div>
        </div>

        <div class="tile">
          <div class="label">Private IP</div>
          <div class="value">${LOCAL_IP}</div>
        </div>

        <div class="tile">
          <div class="label">Availability Zone</div>
          <div class="value">${AZ}</div>
        </div>
      </div>

      <div class="footer">
        Built for geo-routing validation, origin testing, and quick infrastructure verification.
        Health check endpoint: <strong>/health</strong>
        <div class="kanji-strip">CURSED ENERGY • EDGE ROUTING • DOMAIN STABILITY • ORIGIN CONTROL</div>
      </div>
    </div>
  </div>
</body>
</html>
EOF

systemctl is-active httpd
curl -fsS http://localhost/health