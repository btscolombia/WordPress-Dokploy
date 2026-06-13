This project includes **Filestash** as an optional file manager service. It offers a clean, modern interface similar to Dropbox/Google Drive, and mounts the WordPress volume so you can browse and manage your files from the browser.

## 🛠️ How to Enable in Dokploy

Filestash is categorized under the `tools` profile.

1.  Log in to your **Dokploy** panel.
2.  Navigate to your **Project -> Environment Variables**.
3.  Add or update the following variable:
    ```env
    COMPOSE_PROFILES=tools
    ```
4.  **Save** and **Deploy** the project.
5.  **Accessing Filestash**:
    - You must add a **Domain** or **Port** to the `filestash` service in the Dokploy UI.
    - The internal container port is **`8334`**.
    - If testing locally, it is available at `http://localhost:8082`.

## ⚙️ Key Configuration Details

### 1. First-Time Setup
When you access Filestash for the first time, it will ask you to set an **admin password**. Set a strong password immediately.

### 2. Connecting to WordPress Files
After logging in, add a storage connection:
- **Backend**: `Local filesystem`
- **Path**: `/app/data/files/wp_app`

This gives you full access to your WordPress installation (`/var/www/html`).

### 3. Data Persistence
All Filestash settings and state are stored in the `filestash_data` volume, mounted at `/app/data/state` inside the container.

## 🔐 Security Recommendations

> [!WARNING]
> Web-based file managers are high-security risks if not protected.

- **Set Password on First Login**: Filestash requires you to create a password on first access — do this immediately.
- **HTTPS**: Always use a domain with SSL (HTTPS) when accessing Filestash.
- **Disable when not in use**: Set `COMPOSE_PROFILES=` (empty) and redeploy to stop the service when your maintenance task is finished.
- **IP Restriction**: Use Dokploy's advanced settings or a firewall to restrict access to your specific IP address.

## 🔄 Zero-Downtime Permission Healing

If you frequently upload files via Filestash and want to ensure they are always converted back to the correct WordPress permissions (`nobody`) without restarting your site, you can set up a **Dokploy Scheduler** task:

1.  Navigate to the **Scheduler** tab in your project.
2.  Add a new task:
    - **Name**: `Daily Permission Healing`
    - **Schedule**: `0 3 * * *` (Every night at 3 AM)
    - **Service**: `wordpress`
    - **Command**: `chown -R nobody:nogroup /var/www/html`
3.  This ensures all files are correctly owned every 24 hours with **zero downtime**.

---
*For more details on optional services, see [Optional Services](Optional-Services.md).*
