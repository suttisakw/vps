# VPS Services with Cloudflare Tunnel + NPM

ระบบ VPS ที่ใช้ **Cloudflare Tunnel** + **Nginx Proxy Manager (NPM)** สำหรับรัน services หลัก (n8n, Node-RED, PostgreSQL, Redis)

## 🎯 เป้าหมาย

- ใช้ Cloudflare domain
- ใช้ Cloudflare Tunnel (ไม่ต้องเปิด inbound ports)
- ใช้ Nginx Proxy Manager (NPM) จัดการ SSL / Reverse Proxy
- รัน services ใน Docker containers

## 📋 VPS Requirements

### ขั้นต่ำ (แนะนำ)
- **CPU**: 2 vCPU
- **RAM**: 4 GB
- **Storage**: 40 GB SSD
- **OS**: Ubuntu 22.04 LTS
- **Network**: ไม่ต้องเปิด inbound ports

## 🚀 วิธี Setup แบบละเอียด

### 📋 ขั้นตอนที่ 1: เตรียม VPS

#### 1.1 สร้าง VPS ใหม่
- ใช้ Ubuntu 22.04 LTS
- ขนาดขั้นต่ำ: 2 vCPU, 4GB RAM, 40GB SSD
- **ไม่ต้องเปิด inbound ports** (ใช้ Cloudflare Tunnel)

#### 1.2 เชื่อมต่อ VPS
```bash
ssh root@your-vps-ip
# หรือ
ssh ubuntu@your-vps-ip
```

#### 1.3 อัปเดตระบบ
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget
```

### 📁 ขั้นตอนที่ 2: ดาวน์โหลด Project

#### 2.1 Clone Repository
```bash
git clone <your-repo-url>
cd vps_project
```

#### 2.2 หรือสร้างไฟล์เอง
```bash
mkdir vps_project
cd vps_project
# Copy ไฟล์ทั้งหมดจาก project นี้
```

### ⚙️ ขั้นตอนที่ 3: ตั้งค่า Environment

#### 3.1 สร้างไฟล์ .env
```bash
cp env.example .env
nano .env
```

#### 3.2 แก้ไขข้อมูลใน .env
```bash
# Database Configuration
POSTGRES_PASSWORD=your_very_strong_postgres_password_123!
N8N_PASSWORD=your_very_strong_n8n_password_456!

# Domain Configuration (ใช้ domain ของคุณ)
N8N_HOST=n8n.adalindawongsa.com
NODE_RED_HOST=nodered.adalindawongsa.com
NPM_HOST=npm.adalindawongsa.com

# Cloudflare Tunnel Configuration
CLOUDFLARE_TUNNEL_NAME=adalinda-vps-tunnel

# Security Settings
TZ=Asia/Bangkok

# Grafana Configuration (สำหรับ monitoring)
GRAFANA_PASSWORD=your_strong_grafana_password_789!
```

**⚠️ สำคัญ**: เปลี่ยนรหัสผ่านทั้งหมดเป็นรหัสที่แข็งแกร่ง!

### 🐳 ขั้นตอนที่ 4: ติดตั้ง Docker และ Services

#### 4.1 รัน Setup Script อัตโนมัติ
```bash
chmod +x setup.sh
./setup.sh
```

#### 4.2 หรือติดตั้งด้วยตนเอง

**4.2.1 ติดตั้ง Docker**
```bash
# ติดตั้ง dependencies
sudo apt install -y ca-certificates curl gnupg lsb-release

# เพิ่ม Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# เพิ่ม Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ติดตั้ง Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# เพิ่ม user เข้า docker group
sudo usermod -aG docker $USER
```

**4.2.2 ติดตั้ง Cloudflared**
```bash
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    -o cloudflared.deb
sudo dpkg -i cloudflared.deb
rm cloudflared.deb
```

**4.2.3 สร้าง directories**
```bash
mkdir -p cloudflared
mkdir -p init-scripts
mkdir -p backup
```

**4.2.4 เริ่ม Docker services**
```bash
docker compose up -d
```

### 🌐 ขั้นตอนที่ 5: ตั้งค่า Cloudflare Tunnel

#### 5.1 Login เข้า Cloudflare
```bash
chmod +x install-cloudflared.sh
./install-cloudflared.sh
```

หรือทำด้วยตนเอง:

```bash
# Login เข้า Cloudflare (จะเปิด browser)
cloudflared tunnel login
```

#### 5.2 สร้าง Tunnel
```bash
# สร้าง tunnel ใหม่
cloudflared tunnel create adalinda-vps-tunnel

# บันทึก Tunnel ID ที่ได้ (จะใช้ในขั้นตอนต่อไป)
```

#### 5.3 แก้ไข config file
```bash
nano cloudflared/config.yml
```

ใส่ข้อมูล:
```yaml
tunnel: adalinda-vps-tunnel
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: "*"
    service: http://npm:81
  - service: http_status:404
```

**⚠️ เปลี่ยน `<TUNNEL_ID>` เป็น Tunnel ID จริงที่ได้จากขั้นตอน 5.2**

#### 5.4 สร้าง DNS Records
```bash
# สร้าง DNS records ใน Cloudflare
cloudflared tunnel route dns adalinda-vps-tunnel npm.adalindawongsa.com
cloudflared tunnel route dns adalinda-vps-tunnel n8n.adalindawongsa.com
cloudflared tunnel route dns adalinda-vps-tunnel nodered.adalindawongsa.com
cloudflared tunnel route dns adalinda-vps-tunnel pgadmin.adalindawongsa.com
```

#### 5.5 รัน Tunnel
```bash
# Test tunnel
cloudflared tunnel --config cloudflared/config.yml run

# หรือรันเป็น service
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

### 🔧 ขั้นตอนที่ 6: ตั้งค่า Nginx Proxy Manager

#### 6.1 เข้า NPM Admin
```
URL: https://npm.adalindawongsa.com
Email: admin@example.com
Password: changeme
```

#### 6.2 เปลี่ยนรหัสผ่าน
1. เข้า NPM Admin
2. ไปที่ **Users** → **Admin User**
3. เปลี่ยนรหัสผ่านใหม่

#### 6.3 เพิ่ม Proxy Hosts

**6.3.1 เพิ่ม n8n Proxy Host**
- ไปที่ **Proxy Hosts** → **Add Proxy Host**
- **Domain Names**: `n8n.adalindawongsa.com`
- **Forward Hostname/IP**: `n8n`
- **Forward Port**: `5678`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- ไปที่ **SSL** tab → เปิด **SSL Certificate** → เลือก **Let's Encrypt**
- กด **Save**

**6.3.2 เพิ่ม Node-RED Proxy Host**
- ไปที่ **Proxy Hosts** → **Add Proxy Host**
- **Domain Names**: `nodered.adalindawongsa.com`
- **Forward Hostname/IP**: `node-red`
- **Forward Port**: `1880`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- ไปที่ **SSL** tab → เปิด **SSL Certificate** → เลือก **Let's Encrypt**
- กด **Save**

**6.3.3 เพิ่ม pgAdmin Proxy Host**
- ไปที่ **Proxy Hosts** → **Add Proxy Host**
- **Domain Names**: `pgadmin.adalindawongsa.com`
- **Forward Hostname/IP**: `pgadmin`
- **Forward Port**: `80`
- เปิด **Block Common Exploits**
- ไปที่ **SSL** tab → เปิด **SSL Certificate** → เลือก **Let's Encrypt**
- กด **Save**

### ✅ ขั้นตอนที่ 7: ตรวจสอบการทำงาน

#### 7.1 ตรวจสอบ Services
```bash
# ดู status ของ services
docker compose ps

# ดู logs
docker compose logs -f
```

#### 7.2 ทดสอบการเข้าถึง
- **NPM Admin**: https://npm.adalindawongsa.com
- **n8n**: https://n8n.adalindawongsa.com
- **Node-RED**: https://nodered.adalindawongsa.com
- **pgAdmin**: https://pgadmin.adalindawongsa.com

#### 7.3 ตั้งค่า n8n
1. เข้า https://n8n.adalindawongsa.com
2. Login ด้วย: `admin` / `รหัสผ่านที่ตั้งใน .env`
3. ตั้งค่า user account ใหม่

#### 7.4 ตั้งค่า Node-RED
1. เข้า https://nodered.adalindawongsa.com
2. เริ่มสร้าง flows ใหม่

#### 7.5 ตั้งค่า pgAdmin
1. เข้า https://pgadmin.adalindawongsa.com
2. Login ด้วย email และ password ที่ตั้งใน .env
3. เพิ่ม PostgreSQL server:
   - คลิกขวาที่ **Servers** → **Register** → **Server**
   - **General** tab:
     - **Name**: `VPS PostgreSQL`
   - **Connection** tab:
     - **Host name/address**: `postgres`
     - **Port**: `5432`
     - **Username**: `n8n`
     - **Password**: `รหัสผ่านจาก .env (POSTGRES_PASSWORD)`
   - คลิก **Save**
4. เริ่มจัดการ database ผ่าน web interface

### 🚀 ขั้นตอนที่ 8: Production Setup (Optional)

#### 8.1 ใช้ Production Docker Compose
```bash
# ใช้ production config พร้อม monitoring
docker compose -f docker-compose.prod.yml up -d

# เปิด monitoring services
docker compose -f docker-compose.prod.yml --profile monitoring up -d
```

#### 8.2 เข้า Monitoring
- **Prometheus**: http://your-vps-ip:9090
- **Grafana**: http://your-vps-ip:3000
  - Username: `admin`
  - Password: `รหัสผ่านที่ตั้งใน .env`

#### 8.3 ตั้งค่า Auto-Update
```bash
# เปิด auto-update service
docker compose -f docker-compose.prod.yml --profile auto-update up -d
```

### 🔒 ขั้นตอนที่ 9: Security Hardening

#### 9.1 ตั้งค่า Firewall
```bash
# ปิด inbound ports ทั้งหมด
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

#### 9.2 ตั้งค่า Fail2Ban
```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

#### 9.3 ตั้งค่า Cloudflare Access (แนะนำ)
1. เข้า Cloudflare Dashboard
2. ไปที่ **Zero Trust** → **Access**
3. สร้าง Access Application สำหรับแต่ละ service
4. ตั้งค่า authentication rules

### 📊 ขั้นตอนที่ 10: Backup และ Maintenance

#### 10.1 สร้าง Backup
```bash
chmod +x backup.sh
./backup.sh
```

#### 10.2 ตั้งค่า Auto Backup (Cron)
```bash
# เพิ่ม cron job สำหรับ backup รายวัน
crontab -e

# เพิ่มบรรทัดนี้:
0 2 * * * /path/to/your/vps_project/backup.sh
```

#### 10.3 Update Services
```bash
# Update images
docker compose pull

# Restart services
docker compose up -d
```

## 📁 ไฟล์สำคัญ

```
vps_project/
├── docker-compose.yml          # Docker services ทั้งหมด
├── .env.example               # ตัวอย่าง environment variables
├── cloudflared/
│   └── config.yml            # Cloudflare Tunnel config
├── setup.sh                  # Script ติดตั้งระบบ
├── install-cloudflared.sh    # Script setup Cloudflare Tunnel
└── README.md                 # คู่มือนี้
```

## 🔧 Services ที่ติดตั้ง

| Service | Port | Description |
|---------|------|-------------|
| **Nginx Proxy Manager** | 81 | จัดการ Reverse Proxy + SSL |
| **n8n** | 5678 | Workflow Automation |
| **Node-RED** | 1880 | Visual Programming |
| **PostgreSQL** | 5432 | Database (internal) |
| **Redis** | 6379 | Cache (internal) |
| **Cloudflared** | - | Tunnel (optional in compose) |

## 🌐 URLs หลัง Setup

- **NPM Admin**: `https://npm.yourdomain.com`
- **n8n**: `https://n8n.yourdomain.com`
- **Node-RED**: `https://nodered.yourdomain.com`

## 🔐 Default Credentials

### Nginx Proxy Manager
- **Email**: `admin@example.com`
- **Password**: `changeme`

### n8n
- **Username**: `admin`
- **Password**: (ดูในไฟล์ `.env`)

## 📝 การตั้งค่าเพิ่มเติม

### 1. แก้ไข .env file

```bash
# Database Configuration
POSTGRES_PASSWORD=your_strong_postgres_password_here
N8N_PASSWORD=your_strong_n8n_password_here

# Domain Configuration
N8N_HOST=n8n.yourdomain.com
NODE_RED_HOST=nodered.yourdomain.com
NPM_HOST=npm.yourdomain.com
```

### 2. ตั้งค่า NPM Proxy Hosts

เข้า `https://npm.yourdomain.com` และเพิ่ม Proxy Hosts:

| Domain | Forward Hostname/IP | Forward Port | SSL |
|--------|-------------------|--------------|-----|
| `n8n.yourdomain.com` | `n8n` | `5678` | ✅ |
| `nodered.yourdomain.com` | `node-red` | `1880` | ✅ |

### 3. Cloudflare DNS Records

สร้าง DNS records ใน Cloudflare:

```
Type: CNAME
Name: npm
Content: <tunnel-id>.cfargotunnel.com

Type: CNAME  
Name: n8n
Content: <tunnel-id>.cfargotunnel.com

Type: CNAME
Name: nodered
Content: <tunnel-id>.cfargotunnel.com
```

## 🛠️ Commands ที่มีประโยชน์

### Docker Management

```bash
# ดู status services
docker compose ps

# ดู logs
docker compose logs -f

# Restart services
docker compose restart

# Update services
docker compose pull
docker compose up -d

# Stop services
docker compose down
```

### Backup

```bash
# Backup volumes
docker run --rm -v postgres_data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
docker run --rm -v n8n_data:/data -v $(pwd)/backup:/backup alpine tar czf /backup/n8n_backup.tar.gz -C /data .
```

### Cloudflare Tunnel

```bash
# ดู tunnel status
cloudflared tunnel list

# Test tunnel
cloudflared tunnel --config cloudflared/config.yml run

# Delete tunnel (ถ้าต้องการ)
cloudflared tunnel delete <tunnel-name>
```

## 🔒 Security Best Practices

1. **เปลี่ยน default passwords** ใน `.env`
2. **ใช้ strong passwords** สำหรับ database
3. **เปิด Cloudflare Access/Zero Trust** สำหรับ authentication
4. **ปิด inbound ports** ใน VPS firewall
5. **Backup ข้อมูล** เป็นประจำ
6. **Update services** เป็นประจำ

## 🆘 Troubleshooting แบบละเอียด

### 🔍 Services ไม่ขึ้น

#### ตรวจสอบ Docker Services
```bash
# ดู status ของ services
docker compose ps

# ดู logs แบบ real-time
docker compose logs -f

# ดู logs ของ service เฉพาะ
docker compose logs -f n8n
docker compose logs -f postgres
docker compose logs -f redis
```

#### ตรวจสอบ Ports
```bash
# ดู ports ที่เปิดอยู่
netstat -tulpn | grep :81   # NPM
netstat -tulpn | grep :5678 # n8n
netstat -tulpn | grep :1880 # Node-RED
netstat -tulpn | grep :5432 # PostgreSQL
```

#### แก้ไขปัญหาที่พบบ่อย
```bash
# Restart services ทั้งหมด
docker compose restart

# Stop และ start ใหม่
docker compose down
docker compose up -d

# ลบ volumes และเริ่มใหม่ (ระวัง! จะลบข้อมูล)
docker compose down -v
docker compose up -d
```

### 🌐 Cloudflare Tunnel ไม่ทำงาน

#### ตรวจสอบ Tunnel Status
```bash
# ดู tunnels ทั้งหมด
cloudflared tunnel list

# ดู tunnel routes
cloudflared tunnel route list

# Test tunnel config
cloudflared tunnel --config cloudflared/config.yml validate
```

#### แก้ไขปัญหาทั่วไป
```bash
# ตรวจสอบ credentials file
ls -la ~/.cloudflared/

# ตรวจสอบ config file
cat cloudflared/config.yml

# รัน tunnel แบบ debug
cloudflared tunnel --config cloudflared/config.yml run --loglevel debug
```

#### ตั้งค่า Tunnel Service ใหม่
```bash
# ลบ service เก่า
sudo cloudflared service uninstall

# ติดตั้งใหม่
sudo cloudflared service install

# เริ่ม service
sudo systemctl start cloudflared
sudo systemctl status cloudflared
```

### 🔐 SSL ไม่ทำงาน

#### ตรวจสอบ DNS
```bash
# ตรวจสอบ DNS records
nslookup npm.adalindawongsa.com
nslookup n8n.adalindawongsa.com
nslookup nodered.adalindawongsa.com

# ตรวจสอบจาก VPS
dig npm.adalindawongsa.com
```

#### ตรวจสอบ NPM SSL
1. เข้า NPM Admin: https://npm.adalindawongsa.com
2. ไปที่ **SSL Certificates**
3. ตรวจสอบว่า certificate ถูกสร้างแล้ว
4. ตรวจสอบ **Proxy Hosts** → **SSL** tab

#### แก้ไข SSL Issues
```bash
# ลบ SSL certificate เก่า
rm -rf npm_letsencrypt/*

# Restart NPM
docker compose restart npm

# ตรวจสอบ logs
docker compose logs -f npm
```

### 🗄️ Database Issues

#### PostgreSQL Connection Issues
```bash
# ตรวจสอบ PostgreSQL logs
docker compose logs -f postgres

# เข้า PostgreSQL container
docker compose exec postgres psql -U n8n -d n8n

# ตรวจสอบ database
docker compose exec postgres psql -U n8n -d n8n -c "\l"
```

#### Redis Issues
```bash
# ตรวจสอบ Redis logs
docker compose logs -f redis

# Test Redis connection
docker compose exec redis redis-cli ping

# ตรวจสอบ Redis info
docker compose exec redis redis-cli info
```

### 📊 Performance Issues

#### ตรวจสอบ Resource Usage
```bash
# ดู Docker stats
docker stats

# ดู disk usage
df -h
du -sh ./*

# ดู memory usage
free -h
```

#### Optimize Performance
```bash
# ล้าง Docker cache
docker system prune -a

# ตรวจสอบ volumes
docker volume ls
docker volume inspect vps_project_postgres_data
```

## 📋 Quick Reference

### 🔗 URLs และ Ports

| Service | Local Port | External URL | Admin Access |
|---------|------------|--------------|--------------|
| NPM | 81 | https://npm.adalindawongsa.com | admin@example.com |
| n8n | 5678 | https://n8n.adalindawongsa.com | admin |
| Node-RED | 1880 | https://nodered.adalindawongsa.com | - |
| pgAdmin | 80 | https://pgadmin.adalindawongsa.com | admin@adalindawongsa.com |
| Prometheus | 9090 | http://vps-ip:9090 | - |
| Grafana | 3000 | http://vps-ip:3000 | admin |

### ⚡ Quick Commands

```bash
# ดู status ทั้งหมด
docker compose ps

# Restart service เฉพาะ
docker compose restart n8n

# ดู logs
docker compose logs -f

# Backup ข้อมูล
./backup.sh

# Update services
docker compose pull && docker compose up -d

# ตรวจสอบ tunnel
cloudflared tunnel list
```

### 🔧 Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `.env` | Environment variables | Project root |
| `docker-compose.yml` | Basic services | Project root |
| `docker-compose.prod.yml` | Production + monitoring | Project root |
| `cloudflared/config.yml` | Tunnel configuration | cloudflared/ |
| `prometheus.yml` | Monitoring config | Project root |

### 🚨 Emergency Procedures

#### Service Down
```bash
# Restart everything
docker compose down && docker compose up -d

# Check logs
docker compose logs --tail=100
```

#### Data Recovery
```bash
# Restore from backup
tar -xzf backup/20240101_120000.tar.gz

# Copy volumes back
docker compose down
# Copy restored data to volumes
docker compose up -d
```

#### Reset Everything
```bash
# ⚠️ DANGER: This will delete all data
docker compose down -v
rm -rf .env
# Start fresh setup
```

## 📞 Support

หากมีปัญหา สามารถตรวจสอบ logs หรือเปิด issue ใน repository นี้

---

**หมายเหตุ**: ระบบนี้ใช้ Cloudflare Tunnel ดังนั้นไม่จำเป็นต้องเปิด inbound ports ใน VPS firewall
