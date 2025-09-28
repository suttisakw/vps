# 🚀 Deployment Checklist สำหรับ VPS Services

## 📋 Pre-Deployment Checklist

### ✅ VPS Requirements
- [ ] VPS มี RAM 32GB (หรือขั้นต่ำ 4GB)
- [ ] VPS มี CPU 8 cores (หรือขั้นต่ำ 2 cores)
- [ ] VPS มี Storage SSD 100GB+ (หรือขั้นต่ำ 40GB)
- [ ] OS: Ubuntu 22.04 LTS
- [ ] SSH access ได้
- [ ] Internet connection stable

### ✅ Domain & DNS
- [ ] Domain ซื้อแล้ว
- [ ] Domain ตั้งค่าใน Cloudflare
- [ ] DNS records พร้อม (A record หรือ CNAME)
- [ ] Cloudflare account พร้อม

### ✅ Project Files
- [ ] ไฟล์ project ทั้งหมด upload ไป VPS แล้ว
- [ ] ไฟล์ .env แก้ไขแล้ว
- [ ] Scripts มี execute permission

## 🔧 Installation Checklist

### ✅ System Setup
- [ ] `sudo apt update && sudo apt upgrade -y`
- [ ] `sudo apt install -y git curl wget nano`
- [ ] System timezone ตั้งเป็น Asia/Bangkok

### ✅ Docker Installation
- [ ] Docker ติดตั้งแล้ว
- [ ] Docker Compose ติดตั้งแล้ว
- [ ] User อยู่ใน docker group
- [ ] Docker service ทำงานแล้ว

### ✅ Cloudflared Installation
- [ ] Cloudflared ติดตั้งแล้ว
- [ ] `cloudflared tunnel login` สำเร็จ
- [ ] Tunnel สร้างแล้ว
- [ ] Tunnel ID บันทึกแล้ว

### ✅ Environment Configuration
- [ ] ไฟล์ .env แก้ไขแล้ว
- [ ] รหัสผ่านเปลี่ยนแล้ว
- [ ] Domain names ตั้งค่าแล้ว
- [ ] Passwords แข็งแกร่งแล้ว

## 🐳 Docker Services Checklist

### ✅ Basic Services
- [ ] `docker compose up -d` รันสำเร็จ
- [ ] NPM container ทำงานแล้ว
- [ ] n8n container ทำงานแล้ว
- [ ] Node-RED container ทำงานแล้ว
- [ ] PostgreSQL container ทำงานแล้ว
- [ ] Redis container ทำงานแล้ว
- [ ] pgAdmin container ทำงานแล้ว

### ✅ High Performance Services (Optional)
- [ ] `docker compose -f docker-compose.high-performance.yml up -d` รันสำเร็จ
- [ ] Resource limits ตั้งค่าแล้ว
- [ ] Performance monitoring เปิดแล้ว

### ✅ Monitoring Services (Optional)
- [ ] Prometheus container ทำงานแล้ว
- [ ] Grafana container ทำงานแล้ว
- [ ] Monitoring profiles เปิดแล้ว

## 🌐 Cloudflare Tunnel Checklist

### ✅ Tunnel Configuration
- [ ] cloudflared/config.yml แก้ไขแล้ว
- [ ] Tunnel ID ใส่ใน config แล้ว
- [ ] Tunnel service ติดตั้งแล้ว
- [ ] `sudo systemctl enable cloudflared`
- [ ] `sudo systemctl start cloudflared`
- [ ] `sudo systemctl status cloudflared` แสดง running

### ✅ DNS Records
- [ ] `npm.yourdomain.com` DNS record สร้างแล้ว
- [ ] `n8n.yourdomain.com` DNS record สร้างแล้ว
- [ ] `nodered.yourdomain.com` DNS record สร้างแล้ว
- [ ] `pgadmin.yourdomain.com` DNS record สร้างแล้ว

### ✅ Tunnel Routes
- [ ] `cloudflared tunnel route dns tunnel-name npm.yourdomain.com`
- [ ] `cloudflared tunnel route dns tunnel-name n8n.yourdomain.com`
- [ ] `cloudflared tunnel route dns tunnel-name nodered.yourdomain.com`
- [ ] `cloudflared tunnel route dns tunnel-name pgadmin.yourdomain.com`

## 🔧 NPM Configuration Checklist

### ✅ NPM Access
- [ ] เข้า https://npm.yourdomain.com ได้
- [ ] Login ด้วย admin@example.com / changeme
- [ ] รหัสผ่าน admin เปลี่ยนแล้ว

### ✅ Proxy Hosts
- [ ] n8n proxy host สร้างแล้ว
  - Domain: n8n.yourdomain.com
  - Forward: n8n:5678
  - SSL: Let's Encrypt enabled
- [ ] Node-RED proxy host สร้างแล้ว
  - Domain: nodered.yourdomain.com
  - Forward: node-red:1880
  - SSL: Let's Encrypt enabled
- [ ] pgAdmin proxy host สร้างแล้ว
  - Domain: pgadmin.yourdomain.com
  - Forward: pgadmin:80
  - SSL: Let's Encrypt enabled

### ✅ SSL Certificates
- [ ] SSL certificates สร้างแล้ว
- [ ] Force HTTPS เปิดแล้ว
- [ ] SSL certificates ยังไม่หมดอายุ

## ✅ Service Access Checklist

### ✅ Web Interfaces
- [ ] NPM Admin: https://npm.yourdomain.com
- [ ] n8n: https://n8n.yourdomain.com
- [ ] Node-RED: https://nodered.yourdomain.com
- [ ] pgAdmin: https://pgadmin.yourdomain.com

### ✅ Service Configuration
- [ ] n8n login สำเร็จ
- [ ] n8n user account ตั้งค่าแล้ว
- [ ] pgAdmin login สำเร็จ
- [ ] PostgreSQL server connection ใน pgAdmin
- [ ] Node-RED flows เริ่มสร้างได้

### ✅ Database Access
- [ ] pgAdmin เชื่อมต่อ PostgreSQL ได้
- [ ] n8n เชื่อมต่อ PostgreSQL ได้
- [ ] Redis connection ทำงานได้

## 🔒 Security Checklist

### ✅ Basic Security
- [ ] รหัสผ่าน default เปลี่ยนแล้ว
- [ ] Strong passwords ใช้แล้ว
- [ ] Firewall ตั้งค่าแล้ว
- [ ] SSH keys ใช้แล้ว (ไม่ใช้ password)

### ✅ Advanced Security
- [ ] Fail2Ban ติดตั้งแล้ว
- [ ] Cloudflare Access ตั้งค่าแล้ว
- [ ] IP whitelist ตั้งค่าแล้ว
- [ ] SSL/TLS ทำงานได้

### ✅ Backup Security
- [ ] Backup script ทำงานได้
- [ ] Backup ข้อมูลสำคัญ
- [ ] Backup เก็บในที่ปลอดภัย

## 📊 Monitoring Checklist

### ✅ Basic Monitoring
- [ ] `docker compose ps` แสดง services ทั้งหมด
- [ ] `docker compose logs` ไม่มี errors
- [ ] System resources ใช้งานปกติ

### ✅ Advanced Monitoring (Optional)
- [ ] Prometheus metrics ทำงานได้
- [ ] Grafana dashboards ตั้งค่าแล้ว
- [ ] Alerts ตั้งค่าแล้ว
- [ ] Log monitoring ทำงานได้

## 🚀 Performance Checklist

### ✅ Basic Performance
- [ ] Services response time < 2 seconds
- [ ] Memory usage < 80%
- [ ] CPU usage < 80%
- [ ] Disk space > 20% free

### ✅ High Performance (32GB RAM, 8 Core)
- [ ] PostgreSQL memory: 16GB allocated
- [ ] Redis memory: 6GB allocated
- [ ] n8n memory: 4GB allocated
- [ ] Node-RED memory: 2GB allocated
- [ ] High performance config ใช้แล้ว

## 🆘 Troubleshooting Checklist

### ✅ Common Issues
- [ ] Services สามารถ restart ได้
- [ ] Logs ไม่มี critical errors
- [ ] DNS resolution ทำงานได้
- [ ] SSL certificates ยังไม่หมดอายุ

### ✅ Emergency Procedures
- [ ] Backup และ restore procedure ทดสอบแล้ว
- [ ] Rollback plan พร้อมแล้ว
- [ ] Contact information พร้อมแล้ว

## 📝 Post-Deployment Checklist

### ✅ Documentation
- [ ] คู่มือการใช้งาน เขียนแล้ว
- [ ] Emergency contacts บันทึกแล้ว
- [ ] Backup procedures บันทึกแล้ว
- [ ] Monitoring procedures บันทึกแล้ว

### ✅ Maintenance
- [ ] Update schedule กำหนดแล้ว
- [ ] Backup schedule กำหนดแล้ว
- [ ] Monitoring schedule กำหนดแล้ว
- [ ] Security audit schedule กำหนดแล้ว

## 🎯 Final Verification

### ✅ Full System Test
- [ ] ทดสอบเข้าถึง services ทั้งหมด
- [ ] ทดสอบ n8n workflows
- [ ] ทดสอบ Node-RED flows
- [ ] ทดสอบ pgAdmin database access
- [ ] ทดสอบ backup และ restore

### ✅ Performance Test
- [ ] Load testing n8n
- [ ] Database performance test
- [ ] Redis performance test
- [ ] System resource monitoring

### ✅ Security Test
- [ ] Penetration testing
- [ ] SSL/TLS testing
- [ ] Authentication testing
- [ ] Access control testing

---

## 📞 Support Information

### Emergency Contacts
- **System Admin**: [Your contact]
- **Cloudflare Support**: [Support ticket]
- **VPS Provider Support**: [Support contact]

### Important Files Location
- **Config Files**: `/path/to/vps_project/`
- **Backup Location**: `/path/to/vps_project/backup/`
- **Logs**: `docker compose logs`

### Quick Commands
```bash
# Check services status
docker compose ps

# View logs
docker compose logs -f

# Restart services
docker compose restart

# Backup data
./backup.sh

# Update services
docker compose pull && docker compose up -d
```

---

**🎉 หาก checklist ทั้งหมดเสร็จสิ้น ระบบพร้อมใช้งานแล้ว!**
