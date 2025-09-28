# 🚀 VPS Services with Cloudflare Tunnel + NPM

ระบบ VPS ที่ใช้ **Cloudflare Tunnel** + **Nginx Proxy Manager (NPM)** สำหรับรัน services หลัก (n8n, Node-RED, PostgreSQL, Redis, pgAdmin) พร้อม monitoring และ high performance optimization

## 🎯 เป้าหมาย

- ใช้ Cloudflare domain
- ใช้ Cloudflare Tunnel (ไม่ต้องเปิด inbound ports)
- ใช้ Nginx Proxy Manager (NPM) จัดการ SSL / Reverse Proxy
- รัน services ใน Docker containers พร้อม high performance optimization
- Monitoring และ alerting system
- Auto backup และ maintenance

## 📋 VPS Requirements

### ขั้นต่ำ (แนะนำ)
- **CPU**: 2 vCPU (แนะนำ 8 vCPU สำหรับ high performance)
- **RAM**: 4 GB (แนะนำ 32 GB สำหรับ high performance)
- **Storage**: 40 GB SSD (แนะนำ 100 GB+ สำหรับ high performance)
- **OS**: Ubuntu 22.04 LTS
- **Network**: ไม่ต้องเปิด inbound ports

## 🚀 Quick Start

### 1. เตรียม VPS และ Domain

#### 1.1 สร้าง VPS
```bash
# เลือก VPS Provider (DigitalOcean, AWS, Linode, Vultr, etc.)
# ขนาดแนะนำ: 8 vCPU, 32GB RAM, 100GB SSD
# OS: Ubuntu 22.04 LTS
```

#### 1.2 เตรียม Domain
- ซื้อ domain จาก Cloudflare หรือ provider อื่น
- ตั้งค่า DNS ใน Cloudflare

#### 1.3 เชื่อมต่อ VPS
```bash
ssh root@your-vps-ip
# หรือ
ssh ubuntu@your-vps-ip
```

### 2. ติดตั้ง Project

#### 2.1 Clone หรือ Upload ไฟล์
```bash
# วิธีที่ 1: Git clone
git clone https://github.com/yourusername/vps_project.git
cd vps_project

# วิธีที่ 2: Upload ไฟล์ด้วย SCP
scp -r vps_project/ root@your-vps-ip:/root/
ssh root@your-vps-ip
cd vps_project
```

#### 2.2 ตั้งค่า Environment
```bash
# Copy ไฟล์ .env
cp env.example .env

# แก้ไข .env ด้วย nano หรือ vim
nano .env
```

**แก้ไขข้อมูลสำคัญใน .env:**
```bash
# Database Configuration - เปลี่ยนรหัสผ่านให้แข็งแกร่ง
POSTGRES_PASSWORD=your_very_strong_postgres_password_123!
N8N_PASSWORD=your_very_strong_n8n_password_456!

# Domain Configuration - ใช้ domain ของคุณ
N8N_HOST=n8n.yourdomain.com
NODE_RED_HOST=nodered.yourdomain.com
NPM_HOST=npm.yourdomain.com
PGADMIN_HOST=pgadmin.yourdomain.com

# Cloudflare Tunnel Configuration
CLOUDFLARE_TUNNEL_NAME=your-domain-tunnel

# Security Settings
TZ=Asia/Bangkok

# Grafana Configuration
GRAFANA_PASSWORD=your_strong_grafana_password_789!

# pgAdmin Configuration
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=your_strong_pgadmin_password_999!

# High Performance Settings (for 32GB RAM, 8 Core CPU)
# Uncomment these for high-performance setup
# POSTGRES_MAX_CONNECTIONS=200
# POSTGRES_SHARED_BUFFERS=8GB
# POSTGRES_EFFECTIVE_CACHE_SIZE=24GB
# REDIS_MAXMEMORY=4GB
# N8N_MEMORY_LIMIT=4G
# NODE_RED_MEMORY_LIMIT=2G
```

### 3. ติดตั้ง Docker และ Services

#### 3.1 รัน Setup Script
```bash
# ให้สิทธิ์ execute
chmod +x setup.sh

# รัน setup script
./setup.sh
```

#### 3.2 ตรวจสอบการติดตั้ง
```bash
# ตรวจสอบ Docker
docker --version
docker compose version

# ตรวจสอบ Cloudflared
cloudflared version
```

### 4. ตั้งค่า Cloudflare Tunnel

#### 4.1 Login เข้า Cloudflare
```bash
# รัน script setup Cloudflare
chmod +x install-cloudflared.sh
./install-cloudflared.sh
```

หรือทำด้วยตนเอง:
```bash
# Login เข้า Cloudflare
cloudflared tunnel login
# จะเปิด browser ให้ authenticate
```

#### 4.2 สร้าง Tunnel
```bash
# สร้าง tunnel ใหม่ (ใช้ชื่อเดียวกับใน .env)
cloudflared tunnel create your-domain-tunnel

# บันทึก Tunnel ID ที่ได้ (สำคัญ!)
```

#### 4.3 แก้ไข config file
```bash
nano cloudflared/config.yml
```

ใส่ข้อมูล:
```yaml
tunnel: your-domain-tunnel
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: "*"
    service: http://npm:81
  - service: http_status:404
```

**⚠️ เปลี่ยน `<TUNNEL_ID>` เป็น Tunnel ID จริง**

#### 4.4 สร้าง DNS Records
```bash
# สร้าง DNS records สำหรับแต่ละ subdomain
cloudflared tunnel route dns your-domain-tunnel npm.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel n8n.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel nodered.yourdomain.com
cloudflared tunnel route dns your-domain-tunnel pgadmin.yourdomain.com
```

#### 4.5 รัน Tunnel เป็น Service
```bash
# ติดตั้ง tunnel เป็น system service
sudo cloudflared service install

# เริ่ม service
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# ตรวจสอบ status
sudo systemctl status cloudflared
```

### 5. ตั้งค่า Nginx Proxy Manager

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
- **Forward Hostname/IP**: `n8n`
- **Forward Port**: `5678`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- ไปที่ **SSL** tab → เปิด **SSL Certificate** → เลือก **Let's Encrypt**
- กด **Save**

**5.3.2 เพิ่ม Node-RED Proxy Host**
- **Domain Names**: `nodered.yourdomain.com`
- **Forward Hostname/IP**: `node-red`
- **Forward Port**: `1880`
- เปิด **Block Common Exploits**
- เปิด **Websockets Support**
- **SSL**: Let's Encrypt

**5.3.3 เพิ่ม pgAdmin Proxy Host**
- **Domain Names**: `pgadmin.yourdomain.com`
- **Forward Hostname/IP**: `pgadmin`
- **Forward Port**: `80`
- เปิด **Block Common Exploits**
- **SSL**: Let's Encrypt

### 6. รัน Services

#### 6.1 รัน Basic Services
```bash
# รัน services หลัก
docker compose up -d
```

#### 6.2 รันพร้อม Monitoring (แนะนำ)
```bash
# รัน services พร้อม monitoring
docker compose --profile monitoring up -d
```

#### 6.3 รันพร้อม Auto-Update (แนะนำ)
```bash
# รัน services พร้อม auto-update
docker compose --profile auto-update up -d
```

#### 6.4 รันทั้งหมด (Production)
```bash
# รัน services ทั้งหมด (monitoring + auto-update)
docker compose --profile monitoring --profile auto-update up -d
```

### 7. ตรวจสอบและทดสอบ

#### 7.1 ตรวจสอบ Services
```bash
# ดู status ของ services
docker compose ps

# ดู logs
docker compose logs -f

# ตรวจสอบ tunnel
cloudflared tunnel list
```

#### 7.2 ทดสอบการเข้าถึง
- **NPM Admin**: https://npm.yourdomain.com
- **n8n**: https://n8n.yourdomain.com
- **Node-RED**: https://nodered.yourdomain.com
- **pgAdmin**: https://pgadmin.yourdomain.com
- **Prometheus**: http://your-vps-ip:9090
- **Grafana**: http://your-vps-ip:3000

#### 7.3 ตั้งค่า Services

**ตั้งค่า n8n:**
1. เข้า https://n8n.yourdomain.com
2. Login: `admin` / รหัสผ่านจาก .env
3. ตั้งค่า user account ใหม่

**ตั้งค่า pgAdmin:**
1. เข้า https://pgadmin.yourdomain.com
2. Login: admin@yourdomain.com / รหัสผ่านจาก .env
3. เพิ่ม PostgreSQL server:
   - **Name**: `VPS PostgreSQL`
   - **Host**: `postgres`
   - **Port**: `5432`
   - **Username**: `n8n`
   - **Password**: รหัสผ่านจาก .env

**ตั้งค่า Grafana:**
1. เข้า http://your-vps-ip:3000
2. Login: `admin` / รหัสผ่านจาก .env
3. Import dashboards สำหรับ monitoring

## 🔧 Services ที่ติดตั้ง

| Service | Port | External URL | Admin Access | Memory | CPU |
|---------|------|--------------|--------------|--------|-----|
| **Nginx Proxy Manager** | 81 | https://npm.yourdomain.com | admin@example.com | 1GB | 1 core |
| **n8n** | 5678 | https://n8n.yourdomain.com | admin | 4GB | 2 cores |
| **Node-RED** | 1880 | https://nodered.yourdomain.com | - | 2GB | 1 core |
| **PostgreSQL** | 5432 | - | - | 16GB | 4 cores |
| **pgAdmin** | 80 | https://pgadmin.yourdomain.com | admin@yourdomain.com | 1GB | 0.5 cores |
| **Redis** | 6379 | - | - | 6GB | 1 core |
| **Prometheus** | 9090 | http://vps-ip:9090 | - | 2GB | 1 core |
| **Grafana** | 3000 | http://vps-ip:3000 | admin | 1GB | 0.5 cores |

## 📊 High Performance Features

### Resource Optimization (32GB RAM, 8 Core CPU)
- **PostgreSQL**: 16GB RAM, 4 CPU cores
- **Redis**: 6GB RAM, 1 CPU core
- **n8n**: 4GB RAM, 2 CPU cores
- **Node-RED**: 2GB RAM, 1 CPU core
- **Others**: 3GB RAM, 0.5 CPU cores

### Performance Optimizations
- **PostgreSQL**: shared_buffers 8GB, work_mem 64MB
- **Redis**: maxmemory 4GB, allkeys-lru policy
- **n8n**: NODE_OPTIONS --max_old_space_size=2048
- **Node-RED**: NODE_OPTIONS --max_old_space_size=2048

## 🔒 Security Features

### Basic Security
- **Strong passwords** configuration
- **SSL/TLS** encryption ผ่าน Let's Encrypt
- **Firewall** configuration
- **Health checks** สำหรับทุก services

### Advanced Security
- **Resource limits** สำหรับทุก containers
- **Cloudflare Access/Zero Trust** integration
- **Fail2Ban** protection
- **Enhanced cookie protection** สำหรับ pgAdmin

## 📁 ไฟล์สำคัญ

```
vps_project/
├── docker-compose.yml          # Docker services ทั้งหมด (high performance)
├── env.example                 # ตัวอย่าง environment variables
├── cloudflared/
│   └── config.yml            # Cloudflare Tunnel config
├── postgresql.conf            # PostgreSQL high performance config
├── redis.conf                 # Redis high performance config
├── prometheus.yml             # Prometheus monitoring config
├── nginx-static.conf          # Nginx static files config
├── setup.sh                   # Script ติดตั้งระบบ
├── install-cloudflared.sh     # Script setup Cloudflare Tunnel
├── backup.sh                  # Script backup ข้อมูล
├── HIGH_PERFORMANCE_SETUP.md  # คู่มือ high performance
├── DEPLOYMENT_CHECKLIST.md    # Checklist การ deploy
└── README.md                  # คู่มือนี้
```

## 🛠️ Commands ที่มีประโยชน์

### Docker Management
```bash
# ดู status services
docker compose ps

# ดู logs
docker compose logs -f

# ดู logs ของ service เฉพาะ
docker compose logs -f n8n

# Restart services
docker compose restart

# Restart service เฉพาะ
docker compose restart n8n

# Update services
docker compose pull
docker compose up -d

# Stop services
docker compose down

# ดู resource usage
docker stats
```

### Monitoring
```bash
# เข้า Prometheus
curl http://localhost:9090

# เข้า Grafana
curl http://localhost:3000

# ดู system metrics
htop
free -h
df -h
```

### Backup
```bash
# สร้าง backup
./backup.sh

# Backup PostgreSQL
docker compose exec postgres pg_dump -U n8n n8n > backup/n8n_$(date +%Y%m%d).sql

# Restore PostgreSQL
docker compose exec -T postgres psql -U n8n -d n8n < backup/n8n_20240101.sql
```

### Cloudflare Tunnel
```bash
# ดู tunnel status
cloudflared tunnel list

# Test tunnel
cloudflared tunnel --config cloudflared/config.yml run

# ดู tunnel routes
cloudflared tunnel route list
```

## 🔒 Security Best Practices

1. **เปลี่ยน default passwords** ใน `.env`
2. **ใช้ strong passwords** สำหรับ database
3. **เปิด Cloudflare Access/Zero Trust** สำหรับ authentication
4. **ปิด inbound ports** ใน VPS firewall
5. **Backup ข้อมูล** เป็นประจำ
6. **Update services** เป็นประจำ
7. **Monitor logs** เป็นประจำ
8. **ตั้งค่า alerts** สำหรับ critical events

## 🆘 Troubleshooting

### Services ไม่ขึ้น
```bash
# ดู logs
docker compose logs

# ตรวจสอบ ports
netstat -tulpn | grep :81
netstat -tulpn | grep :5678

# Restart services
docker compose restart
```

### Cloudflare Tunnel ไม่ทำงาน
```bash
# ตรวจสอบ tunnel status
cloudflared tunnel list

# Test tunnel config
cloudflared tunnel --config cloudflared/config.yml validate

# ตรวจสอบ service
sudo systemctl status cloudflared
```

### SSL ไม่ทำงาน
```bash
# ตรวจสอบ DNS
nslookup npm.yourdomain.com

# ลบ SSL certificate เก่า
rm -rf npm_letsencrypt/*
docker compose restart npm
```

### Performance Issues
```bash
# ดู resource usage
docker stats
free -h
htop

# ตรวจสอบ PostgreSQL performance
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;"
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] VPS specs (8 vCPU, 32GB RAM, 100GB SSD)
- [ ] Domain ซื้อและตั้งค่า DNS
- [ ] SSH access ได้
- [ ] Project files upload แล้ว

### Installation
- [ ] .env file แก้ไขแล้ว
- [ ] Docker และ Cloudflared ติดตั้งแล้ว
- [ ] Services รันได้แล้ว
- [ ] Cloudflare Tunnel ตั้งค่าแล้ว

### Configuration
- [ ] NPM Proxy Hosts สร้างแล้ว
- [ ] SSL certificates ทำงานได้
- [ ] Services เข้าถึงได้ผ่าน web
- [ ] Monitoring ทำงานได้

### Security
- [ ] รหัสผ่านเปลี่ยนแล้ว
- [ ] Firewall ตั้งค่าแล้ว
- [ ] Backup ทำงานได้
- [ ] Monitoring alerts ตั้งค่าแล้ว

## 📞 Support

หากมีปัญหา สามารถ:
1. ตรวจสอบ logs: `docker compose logs -f`
2. ตรวจสอบ status: `docker compose ps`
3. ดู troubleshooting guide
4. เปิด issue ใน repository

---

**🎉 ระบบพร้อมใช้งานแล้ว!**

**หมายเหตุ**: ระบบนี้ใช้ Cloudflare Tunnel ดังนั้นไม่จำเป็นต้องเปิด inbound ports ใน VPS firewall