# 🚀 VPS Services Setup Guide (รวม Cloudflared ใน Docker Network)

คู่มือการ setup VPS Services ที่ cloudflared รันใน Docker network เดียวกันกับ containers อื่นๆ

## 🎯 ข้อดีของการรัน Cloudflared ใน Docker Network

- **Security**: ไม่ต้องเปิด inbound ports ใน VPS
- **Simplicity**: จัดการผ่าน Docker Compose เดียวกัน
- **Reliability**: Auto restart และ health checks
- **Monitoring**: Monitor ได้ผ่าน Docker logs
- **Resource Management**: จำกัด resources ได้

## 📋 Prerequisites

- VPS พร้อม Ubuntu 22.04 LTS
- Domain ที่จัดการผ่าน Cloudflare
- Docker และ Docker Compose ติดตั้งแล้ว
- Cloudflare account

## 🔧 ขั้นตอนการ Setup

### ขั้นตอนที่ 1: เตรียม Environment

#### 1.1 แก้ไขไฟล์ .env
```bash
# Copy และแก้ไข .env
cp env.example .env
nano .env
```

**ข้อมูลสำคัญที่ต้องแก้ไข:**
```bash
# Database Configuration
POSTGRES_PASSWORD=your_very_strong_postgres_password_123!
N8N_PASSWORD=your_very_strong_n8n_password_456!

# Domain Configuration (ใช้ domain ของคุณ)
N8N_HOST=n8n.yourdomain.com
NODE_RED_HOST=nodered.yourdomain.com
NPM_HOST=npm.yourdomain.com
PGADMIN_HOST=pgadmin.yourdomain.com

# Cloudflare Tunnel Configuration
CLOUDFLARE_TUNNEL_NAME=your-domain-tunnel

# pgAdmin Configuration
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your_strong_pgadmin_password_999!

# Grafana Configuration
GRAFANA_PASSWORD=your_strong_grafana_password_789!
```

### ขั้นตอนที่ 2: ติดตั้ง Cloudflare Tunnel

#### 2.1 ติดตั้ง Cloudflared บน VPS
```bash
# ติดตั้ง cloudflared
curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb
rm cloudflared.deb

# ตรวจสอบการติดตั้ง
cloudflared version
```

#### 2.2 Login เข้า Cloudflare
```bash
# Login เข้า Cloudflare (จะเปิด browser)
cloudflared tunnel login

# ตรวจสอบว่า login สำเร็จ
ls -la ~/.cloudflared/
```

#### 2.3 สร้าง Tunnel
```bash
# สร้าง tunnel ใหม่ (ใช้ชื่อเดียวกับใน .env)
cloudflared tunnel create your-domain-tunnel

# บันทึก Tunnel ID ที่ได้ (สำคัญ!)
# ตัวอย่าง: Tunnel ID: 12345678-1234-1234-1234-123456789abc
```

#### 2.4 แก้ไข Config File
```bash
# แก้ไข cloudflared/config.yml
nano cloudflared/config.yml
```

**ใส่ข้อมูล:**
```yaml
tunnel: your-domain-tunnel
credentials-file: /root/.cloudflared/12345678-1234-1234-1234-123456789abc.json

# Ingress rules for routing traffic through internal Docker network
ingress:
  # Route all traffic to Nginx Proxy Manager (internal network)
  - hostname: "*"
    service: http://npm:81
  # Catch-all rule
  - service: http_status:404
```

**⚠️ เปลี่ยน `12345678-1234-1234-1234-123456789abc` เป็น Tunnel ID จริง**

#### 2.5 สร้าง DNS Records
```bash
# สร้าง DNS records สำหรับแต่ละ subdomain
cloudflared tunnel route dns your-domain-tunnel npm.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel n8n.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel nodered.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel pgadmin.yourdomain.com

# ตรวจสอบ DNS records
cloudflared tunnel route list
```

### ขั้นตอนที่ 3: รัน Docker Services

#### 3.1 รัน Services ทั้งหมด (รวม Cloudflared)
```bash
# รัน services ทั้งหมด
docker compose up -d

# ตรวจสอบ status
docker compose ps
```

#### 3.2 รันพร้อม Monitoring (แนะนำ)
```bash
# รัน services พร้อม monitoring
docker compose --profile monitoring up -d

# ตรวจสอบ status
docker compose ps
```

#### 3.3 รันทั้งหมด (Production)
```bash
# รัน services ทั้งหมด (monitoring + auto-update)
docker compose --profile monitoring --profile auto-update up -d
```

### ขั้นตอนที่ 4: ตรวจสอบ Services

#### 4.1 ตรวจสอบ Docker Services
```bash
# ดู status ของ services
docker compose ps

# ดู logs
docker compose logs -f

# ดู logs ของ cloudflared
docker compose logs -f cloudflared
```

#### 4.2 ตรวจสอบ Network Connectivity
```bash
# ทดสอบการเชื่อมต่อภายใน Docker network
docker compose exec cloudflared ping npm
docker compose exec cloudflared ping n8n
docker compose exec cloudflared ping node-red
docker compose exec cloudflared ping pgadmin
```

#### 4.3 ตรวจสอบ Tunnel Status
```bash
# ดู tunnel status
cloudflared tunnel list

# ดู tunnel routes
cloudflared tunnel route list

# ทดสอบ tunnel config
cloudflared tunnel --config cloudflared/config.yml validate
```

### ขั้นตอนที่ 5: ตั้งค่า Nginx Proxy Manager

#### 5.1 เข้า NPM Admin
```
URL: https://npm.yourdomain.com
Email: admin@example.com
Password: changeme
```

#### 5.2 เปลี่ยนรหัสผ่าน Admin
1. เข้า NPM Admin
2. ไปที่ **Users** → **Admin User**
3. เปลี่ยนรหัสผ่านใหม่

#### 5.3 เพิ่ม Proxy Hosts

**5.3.1 เพิ่ม n8n Proxy Host**
- ไปที่ **Proxy Hosts** → **Add Proxy Host**
- **Domain Names**: `n8n.yourdomain.com`
- **Scheme**: `http`
- **Forward Hostname/IP**: `n8n`
- **Forward Port**: `5678`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- ไปที่ **SSL** tab → เปิด **SSL Certificate** → เลือก **Let's Encrypt**
- กด **Save**

**5.3.2 เพิ่ม Node-RED Proxy Host**
- **Domain Names**: `nodered.yourdomain.com`
- **Scheme**: `http`
- **Forward Hostname/IP**: `node-red`
- **Forward Port**: `1880`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- **SSL**: Let's Encrypt

**5.3.3 เพิ่ม pgAdmin Proxy Host**
- **Domain Names**: `pgadmin.yourdomain.com`
- **Scheme**: `http`
- **Forward Hostname/IP**: `pgadmin`
- **Forward Port**: `80`
- เปิด **Block Common Exploits**
- **SSL**: Let's Encrypt

### ขั้นตอนที่ 6: ทดสอบการเข้าถึง

#### 6.1 ทดสอบ URLs
- **NPM Admin**: https://npm.yourdomain.com
- **n8n**: https://n8n.yourdomain.com
- **Node-RED**: https://nodered.yourdomain.com
- **pgAdmin**: https://pgadmin.yourdomain.com

#### 6.2 ทดสอบจาก Command Line
```bash
# ทดสอบ HTTP response
curl -I https://npm.yourdomain.com
curl -I https://n8n.yourdomain.com
curl -I https://nodered.yourdomain.com
curl -I https://pgadmin.yourdomain.com

# ทดสอบ DNS resolution
nslookup npm.yourdomain.com
nslookup n8n.yourdomain.com
```

### ขั้นตอนที่ 7: ตั้งค่า Services

#### 7.1 ตั้งค่า n8n
1. เข้า https://n8n.yourdomain.com
2. Login: `admin` / รหัสผ่านจาก .env
3. ตั้งค่า user account ใหม่

#### 7.2 ตั้งค่า pgAdmin
1. เข้า https://pgadmin.yourdomain.com
2. Login: admin@yourdomain.com / รหัสผ่านจาก .env
3. เพิ่ม PostgreSQL server:
   - **Name**: `VPS PostgreSQL`
   - **Host**: `postgres`
   - **Port**: `5432`
   - **Username**: `n8n`
   - **Password**: รหัสผ่านจาก .env

#### 7.3 ตั้งค่า Grafana (ถ้าใช้ monitoring)
1. เข้า http://your-vps-ip:3000
2. Login: `admin` / รหัสผ่านจาก .env
3. Import dashboards สำหรับ monitoring

## 🔍 Troubleshooting

### ปัญหา 1: Cloudflared ไม่ทำงาน
```bash
# ตรวจสอบ logs
docker compose logs -f cloudflared

# ตรวจสอบ tunnel status
cloudflared tunnel list

# ตรวจสอบ config
cloudflared tunnel --config cloudflared/config.yml validate
```

### ปัญหา 2: Services ไม่เชื่อมต่อ
```bash
# ตรวจสอบ network
docker network ls
docker network inspect vps_project_services

# ทดสอบ connectivity
docker compose exec cloudflared ping npm
docker compose exec npm ping n8n
```

### ปัญหา 3: DNS ไม่ resolve
```bash
# ตรวจสอบ DNS records
cloudflared tunnel route list

# ตรวจสอบ DNS resolution
nslookup npm.yourdomain.com
dig npm.yourdomain.com
```

### ปัญหา 4: SSL ไม่ทำงาน
```bash
# ลบ SSL certificate เก่า
rm -rf npm_letsencrypt/*

# Restart NPM
docker compose restart npm

# สร้าง SSL certificate ใหม่ใน NPM
```

## 🛠️ Useful Commands

### Docker Management
```bash
# ดู status
docker compose ps

# ดู logs
docker compose logs -f

# Restart services
docker compose restart

# Update services
docker compose pull && docker compose up -d

# ดู resource usage
docker stats
```

### Cloudflared Management
```bash
# ดู tunnel status
cloudflared tunnel list

# ดู tunnel routes
cloudflared tunnel route list

# Test tunnel config
cloudflared tunnel --config cloudflared/config.yml validate

# ดู tunnel logs
docker compose logs -f cloudflared
```

### Network Testing
```bash
# ทดสอบ internal connectivity
docker compose exec cloudflared ping npm
docker compose exec npm curl -I http://n8n:5678

# ทดสอบ external access
curl -I https://npm.yourdomain.com
curl -I https://n8n.yourdomain.com
```

## 📋 Setup Checklist

### Pre-Setup
- [ ] VPS specs (8 vCPU, 32GB RAM, 100GB SSD)
- [ ] Domain ซื้อและตั้งค่าใน Cloudflare
- [ ] Docker และ Docker Compose ติดตั้งแล้ว
- [ ] Cloudflare account พร้อม

### Setup
- [ ] .env file แก้ไขแล้ว
- [ ] Cloudflared ติดตั้งและ login แล้ว
- [ ] Tunnel สร้างและ config แล้ว
- [ ] DNS records สร้างแล้ว
- [ ] Docker services รันได้แล้ว

### Configuration
- [ ] NPM Proxy Hosts สร้างแล้ว
- [ ] SSL certificates ทำงานได้
- [ ] Services เข้าถึงได้ผ่าน web
- [ ] n8n และ pgAdmin ตั้งค่าแล้ว

### Testing
- [ ] ทดสอบ URLs ทั้งหมด
- [ ] ทดสอบ SSL certificates
- [ ] ทดสอบ data integrity
- [ ] ทดสอบ monitoring (ถ้าใช้)

## 🚀 Production Recommendations

### Security
- เปลี่ยนรหัสผ่านทั้งหมด
- เปิด Cloudflare Access/Zero Trust
- ตั้งค่า firewall
- ใช้ strong passwords

### Monitoring
- เปิด monitoring profiles
- ตั้งค่า alerts
- ตรวจสอบ logs เป็นประจำ
- Monitor resource usage

### Backup
- ตั้งค่า auto backup
- เก็บ backup ข้อมูลสำคัญ
- ทดสอบ restore procedure
- ตั้งค่า backup schedule

---

**🎉 ระบบพร้อมใช้งานแล้ว!**

**ข้อดีของวิธีนี้:**
- Cloudflared รันใน Docker network เดียวกัน
- จัดการได้ผ่าน Docker Compose เดียวกัน
- Auto restart และ health checks
- Monitor ได้ผ่าน Docker logs
- Resource management ที่ดีกว่า
