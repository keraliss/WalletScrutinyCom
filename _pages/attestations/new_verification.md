---
layout: archive
title: "Creating New Verification"
permalink: /new_verification/
---

<link rel="stylesheet" href="{{ base_path }}/assets/css/verifications.css">

<script type="text/javascript" src="{{'/dist/verifications.bundle.min.js' | relative_url }}"></script>

<div class="form-container">
  <div class="info-message"></div>

  <div id="previousAttestations" style="margin-bottom: 3em;"></div>

  <div>
    <p>Fields marked with (*) are required.</p>
  </div>

  <form id="attestationForm" onsubmit="handleSubmit(event)">
    <div class="form-group">
      <label for="appId">App ID:</label>
      <input type="text" id="appId" name="appId" class="form-control" autocomplete="off" maxlength="50">
      <div id="appIdSuggestions" class="suggestions-container"></div>
      <small class="form-text">Example: app.zeusln.zeus. Start typing wallet name or ID to search for known apps, or write a new app ID.</small>
      <small class="form-text" style="margin-bottom: 1em;">If you <b>can't find the app here</b>, you can <a href="https://gitlab.com/walletscrutiny/walletScrutinyCom/-/wikis/How-to-Contribute-to-WalletScrutiny#add-products" target="_blank">open an MR</a> to add it to the inventory, or drop us a message on our <a href="https://discord.com/channels/1011450447392940082/1012176837486596106" target="_blank">Discord</a>.</small>
    </div>

    <div class="form-group">
      <label for="version">Version (*):</label>
      <input type="text" id="version" name="version" class="form-control" required maxlength="15">
      <small class="form-text">Example: 0.9.2</small>
    </div>

    <div class="form-group">
      <label for="platform">Platform (*):</label>
      <select id="platform" name="platform" class="form-control" required>
        <option value="">Select a platform</option>
        {% for p in site.data.platformMeta %}
          {% assign folder = p[0] %}
          {% include folderToName.html folder=folder %}
          <option value="{{p[0]}}">{{name}}{% if folder == 'desktop' %} (deprecated){% endif %}</option>
        {% endfor %} 
      </select>
    </div>

    <div class="form-group">
      <label for="description">Asset Description (*):</label>
      <input type="text" id="description" name="description" class="form-control" required maxlength="120">
      <small class="form-text">Example: Firmware / Bootloader / Universal APK from Github / Debian package amd64 / ARM v8 / MacOS App Store</small>
    </div>

    <div class="form-group">
      <label for="status">Status (*):</label>
      <select id="status" name="status" class="form-control" required>
        <option value="">Select a status</option>
        <option value="reproducible">Reproducible</option>
        <option value="not_reproducible">Not Reproducible</option>
        <option value="ftbfs">Failed to Build from Source</option>
        <option value="spam">Spam</option>
        <option value="notag">No git revision</option>
        <option value="nosource">No source</option>
        <option value="obfuscated">Obfuscated</option>
        <option value="warning">Warning</option>
      </select>
    </div>

    <div style="margin-top: 1em; margin-bottom: 2em; font-size:smaller">
      <p>
        <b>Reproducible:</b> You've been able to build the asset and differences with the tested binary are minimal.
      </p>
      <p>
        <b>Not Reproducible:</b> You've been able to build the asset, but differences with the tested binary are significant.
      </p>
      <p>
        <b>Failed to Build from Source:</b> You failed to build the asset from source.
      </p>
      <p>
        <b>Spam:</b> The asset is a spam or is not what it says it is.
      </p>
      <p>
        <b>No git revision:</b> The git revision to compile is not clear.
      </p>
      <p>
        <b>No source:</b> The source for this version was not found or the repository was taken down.
      </p>
      <p>
        <b>Obfuscated:</b> The source code is obfuscated.
      </p>
      <p>
        <b>Warning:</b> If another status could apply but some red flag has come up. Reproducible but known backdoor found, or irreproducible with a discrepancy clearly not benign.
      </p>
    </div>

    <div class="form-group">
      <label for="content">Content (*):</label>
      <div class="char-counter">Characters: <span id="charCount">0</span>/60000</div>
      <textarea id="content" name="content" class="form-control" rows="10" required></textarea>
      <small class="form-text">Describe your verification process and findings with as much detail as possible, including scripts you used and output logs (minimum 20, maximum 60000 characters). Markdown is supported.</small>
    </div>

    <div class="form-group">
      <label for="otherHashes" id="hashesLabel"></label>
      <div class="hash-input-container">
        <input type="text" id="newHash" class="form-control" placeholder="Enter hash">
        <button type="button" id="addHash" class="btn btn-primary" title="Add this hash to the list">
          <i class="fas fa-plus"></i>
        </button>
      </div>
      <div id="hashList" class="hash-list"></div>
      <input type="hidden" id="otherHashes" name="otherHashes">
      <small class="form-text" id="hashesHelpText"></small>
    </div>

    <style>
      .hash-input-container {
        display: flex;
        gap: 10px;
        margin-bottom: 10px;
      }
      .hash-list {
        display: flex;
        flex-direction: column;
        gap: 5px;
      }
      .hash-list:not(:empty) {
        border: 1px solid #ddd;
        border-radius: 4px;
        padding: 8px;
        margin-top: 5px;
      }
      .hash-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 5px;
        border-radius: 4px;
      }
      .hash-item span {
        flex: 1;
        word-break: break-all;
      }
      .remove-hash {
        color: red;
        cursor: pointer;
        border: none;
        background: none;
        padding: 0 5px;
      }
    </style>

    <button type="submit" name="draft" class="btn btn-info" style="margin-right: 1em;">Publish Verification as a Draft</button>
    <button type="submit" name="publish" class="btn btn-success" style="margin-right: 1em;">Publish Verification</button>
    <a id="deleteDraft" style="color: red; cursor: pointer;">Delete Draft</a>
    <p>
      <small>
        <b>Note:</b> Draft verifications are not displayed directly, but they can still be seen by you and other users if they opt to view them. You'll be able to view them and publish them later.
      </small>
    </p>
  </form>
</div>

<div id="verificationModal">
  <span id="closeModal">&times;</span>
  <div id="verificationContent"></div>
</div>

<script>
let hashes = [];
let hashList, otherHashesInput, hashInput;

function updateHiddenInput() {
  if (otherHashesInput) {
    otherHashesInput.value = hashes.join(',');
  }
}

function addHash(hash) {
  if (!hash) return;
  if (hashes.includes(hash)) {
    showToast('This hash is already in the list', 'error');
    return;
  }
  
  if (!hashList) {
    hashList = document.getElementById('hashList');
  }
  
  const hashItem = document.createElement('div');
  hashItem.className = 'hash-item';
  hashItem.innerHTML = `
    <span>${hash}</span>
    <button type="button" class="remove-hash" title="Remove this hash from the list">
      <i class="fas fa-minus"></i>
    </button>
  `;

  hashItem.querySelector('.remove-hash').addEventListener('click', () => {
    hashes = hashes.filter(h => h !== hash);
    hashItem.remove();
    updateHiddenInput();
  });

  hashList.appendChild(hashItem);
  hashes.push(hash);
  updateHiddenInput();
  if (hashInput) {
    hashInput.value = '';
  }
} 

function validateForm() {
  const content = document.getElementById('content').value.trim();

  if (content.length < 20) {
    showToast('Content must be at least 20 characters long', 'error');
    return false;
  }
  if (content.length > 60000) {
    showToast('Content cannot exceed 60000 characters', 'error');
    return false;
  }

  return true;
}

async function loadUrlParamsAndGetAssetInfo() {
  const showError = (message) => {
    document.querySelector('.form-container').style.display = 'none';
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.innerHTML = `
      <p>${message}</p>
      <p><a href="/assets/" class="btn btn-info">Return to assets page</a></p>
    `;
    
    document.querySelector('.form-container').insertAdjacentElement('beforebegin', errorDiv);
  };

  if (!await userHasBrowserExtension()) {
    showError('A Nostr browser extension is required to create verifications.');
    return;
  }

  try {
    await nostrConnect();
  } catch (e) {
    console.error("Failed to connect to Nostr", e);
    showToast('It was impossible to connect to Nostr. Please check your browser extension and try again.', 'error');
    return;
  }

  const urlParams = new URLSearchParams(window.location.search);
  const draftVerificationEventId = urlParams.get('draftVerificationEventId');
  const action = urlParams.get('action');

  if (draftVerificationEventId && action) {
    const draftButton = document.querySelector('button[name="draft"]');
    if (draftButton) {
      draftButton.textContent = 'Save Draft Verification';
    }

    const draftVerificationEvent = await getDraftVerificationEvent(draftVerificationEventId);
    const eventContent = JSON.parse(draftVerificationEvent.content);

    document.getElementById('appId').value = draftVerificationEvent.tags.find(tag => tag[0] === 'i')?.[1] || '';
    document.getElementById('version').value = draftVerificationEvent.tags.find(tag => tag[0] === 'version')?.[1] || '';
    document.getElementById('platform').value = draftVerificationEvent.tags.find(tag => tag[0] === 'platform')?.[1] || '';
    document.getElementById('description').value = eventContent.description || '';
    document.getElementById('status').value = draftVerificationEvent.tags.find(tag => tag[0] === 'status')?.[1] || '';
    document.getElementById('content').value = eventContent.content || '';

    const hashes = draftVerificationEvent.tags?.filter(tag => tag[0] === 'x').map(tag => tag[1]) || [];
    hashes.forEach(hash => addHash(hash));
  } else {
    const deleteDraftBtn = document.getElementById('deleteDraft');
    if (deleteDraftBtn) {
      deleteDraftBtn.style.display = 'none';
    }
  }

  if (window.wallets && window.wallets.length > 0) {
    setupAppIdAutocomplete();
  }

  const fields = ['version', 'appId', 'platform'];
  fields.forEach(field => {
    const value = DOMPurify.sanitize(urlParams.get(field), purifyConfig);
    if (value) {
      document.getElementById(field).value = value;
    }
  });

  const sha256 = DOMPurify.sanitize(urlParams.get('sha256'), purifyConfig);

  // Update the hashes label based on whether sha256 is present
  const hashesLabel = document.getElementById('hashesLabel');
  const hashesHelpText = document.getElementById('hashesHelpText');
  if (sha256) {
    hashesLabel.textContent = 'Additional related hashes:';
    hashesHelpText.textContent = 'If you find other related binaries (e.g., APKs within an AAB) that are also reproducible, you can add the hashes of those additional binaries to your verification.';
  } else {
    hashesLabel.textContent = 'Asset hashes*:';
    hashesHelpText.textContent = 'Add the SHA-256 hash(es) of the asset(s) you are verifying. Each hash must be 64 hexadecimal characters.';
  }

  let message = '';

  if (sha256) {
    // Show asset information and previous verifications
    const result = await renderAssetsTable({
      htmlElementId:'previousAttestations',
      sha256: sha256,
      hideConfig: {buttons: true}
    });

    if (!result.hasVerifications) {
      document.getElementById('previousAttestations').style.display = 'none';
    }

    if (result.hasVerifications) {
      message = '<p>You are about to create a verification for a specific asset. Below you can find the asset information and other verifications that were made. Feel free to review them before creating your own.</p>';
    } else {
      message = '<p>Below you can find the asset information. Since there are no previous verifications, you will be the first one to provide feedback about this asset.</p>';
    }
  }

  message += '<p>To create the verification, fill all the fields, describing your verification process and findings with as much detail as possible.</p>';
  const infoMessage = document.querySelector('.info-message');
  infoMessage.innerHTML = message;
}

async function handleSubmit(event) {
  event.preventDefault();
  
  if (!validateForm()) {
    return;
  }

  const submitter = event.submitter;
  const isDraft = submitter.name === 'draft';

  const sha256 = DOMPurify.sanitize(new URLSearchParams(window.location.search).get('sha256'), purifyConfig);
  const assetEventId = DOMPurify.sanitize(new URLSearchParams(window.location.search).get('assetEventId'), purifyConfig);
  const draftVerificationEventId = DOMPurify.sanitize(new URLSearchParams(window.location.search).get('draftVerificationEventId'), purifyConfig);
  const otherHashesValue = document.getElementById('otherHashes').value.trim();

  // Combine sha256 and otherHashes into a single parameter
  let hashes = sha256 ? [sha256] : [];
  if (otherHashesValue) {
    hashes = hashes.concat(otherHashesValue.split(','));
  }

  const formData = {
    hashes: hashes,
    description: document.getElementById('description').value.trim(),
    content: document.getElementById('content').value.trim(),
    appId: document.getElementById('appId').value.trim(),
    version: document.getElementById('version').value.trim(),
    status: document.getElementById('status').value,
    platform: document.getElementById('platform').value,
    assetEventId: assetEventId,
    isDraft: isDraft,
    draftVerificationEventId: draftVerificationEventId
  };

  const spinner = document.getElementById('loadingSpinner');
  spinner.style.display = 'block';

  try {
    await createVerification(formData);
    spinner.style.display = 'none';
    await showToast(isDraft ? 'Draft published successfully!' : 'Verification published successfully!');
    if (!isDraft) {
      window.location.href = '/asset/?sha256=' + sha256;
    }
  } catch (error) {
    spinner.style.display = 'none';
    showToast(error.message, 'error');
  }
}

function updateCharCount() {
  const content = document.getElementById('content').value;
  const charCount = document.getElementById('charCount');
  charCount.textContent = content.length;
}

document.addEventListener('DOMContentLoaded', function() {
  loadUrlParamsAndGetAssetInfo();

  document.getElementById('content').addEventListener('input', updateCharCount);

  // Hash management
  hashInput = document.getElementById('newHash');
  const addHashBtn = document.getElementById('addHash');
  hashList = document.getElementById('hashList');
  otherHashesInput = document.getElementById('otherHashes');

  const deleteDraftBtn = document.getElementById('deleteDraft');
  deleteDraftBtn.addEventListener('click', async function() {
    const urlParams = new URLSearchParams(window.location.search);
    const draftVerificationEventId = urlParams.get('draftVerificationEventId');
    await deleteDraftVerification(draftVerificationEventId, '/assets/');
  });

  addHashBtn.addEventListener('click', () => {
    const hash = hashInput.value.trim();
    if (!hash) {
      showToast('Please enter a hash value', 'error');
      return;
    }
    if (!/^[a-fA-F0-9]{64}$/.test(hash)) {
      showToast('Invalid hash format. Must be 64 hexadecimal characters', 'error');
      return;
    }
    addHash(hash);
  });

  hashInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      e.preventDefault();
      addHashBtn.click();
    }
  });
});
</script>