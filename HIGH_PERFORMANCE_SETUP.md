# High Performance Setup Guide
## สำหรับ Server 32GB RAM, 8 Core CPU

คู่มือการตั้งค่าระบบ VPS Services สำหรับเครื่อง high-performance

## 🚀 Server Specifications

- **RAM**: 32GB
- **CPU**: 8 Cores
- **Storage**: SSD (แนะนำ 100GB+)
- **OS**: Ubuntu 22.04 LTS

## 📊 Resource Allocation

### Memory Distribution (32GB Total)
- **PostgreSQL**: 16GB (50%)
- **Redis**: 6GB (18.75%)
- **n8n**: 4GB (12.5%)
- **Node-RED**: 2GB (6.25%)
- **pgAdmin**: 1GB (3.125%)
- **NPM**: 1GB (3.125%)
- **System**: 2GB (6.25%)

### CPU Distribution (8 Cores Total)
- **PostgreSQL**: 4 cores (50%)
- **n8n**: 2 cores (25%)
- **Node-RED**: 1 core (12.5%)
- **Redis**: 1 core (12.5%)
- **Others**: Shared

## 🐳 วิธีใช้งาน High Performance Docker Compose

### 1. ใช้ไฟล์ docker-compose.high-performance.yml
```bash
# รัน services พร้อม high performance config
docker compose -f docker-compose.high-performance.yml up -d

# รันพร้อม monitoring
docker compose -f docker-compose.high-performance.yml --profile monitoring up -d

# รันพร้อม auto-update
docker compose -f docker-compose.high-performance.yml --profile auto-update up -d

# รันพร้อม static file serving
docker compose -f docker-compose.high-performance.yml --profile static up -d
```

### 2. ตรวจสอบ Resource Usage
```bash
# ดู resource usage
docker stats

# ดู memory usage
free -h

# ดู CPU usage
htop
```

## 🔧 High Performance Optimizations

### PostgreSQL Optimizations
- **shared_buffers**: 8GB (25% of RAM)
- **effective_cache_size**: 24GB (75% of RAM)
- **work_mem**: 64MB
- **maintenance_work_mem**: 2GB
- **max_connections**: 200
- **WAL buffers**: 16MB

### Redis Optimizations
- **maxmemory**: 4GB
- **maxmemory-policy**: allkeys-lru
- **tcp-keepalive**: 60
- **timeout**: 300
- **maxclients**: 10000

### n8n Optimizations
- **NODE_OPTIONS**: --max_old_space_size=2048
- **N8N_EXECUTIONS_MODE**: queue
- **N8N_PAYLOAD_SIZE_MAX**: 16MB
- **Memory limit**: 4GB

### Node-RED Optimizations
- **NODE_OPTIONS**: --max_old_space_size=2048
- **NODE_ENV**: production
- **Memory limit**: 2GB

## 📈 Monitoring และ Performance

### Prometheus Metrics
```bash
# เข้า Prometheus
http://your-vps-ip:9090

# Metrics ที่สำคัญ:
# - postgresql_up
# - redis_up
# - n8n_up
# - node_red_up
# - container_memory_usage_bytes
# - container_cpu_usage_seconds_total
```

### Grafana Dashboards
```bash
# เข้า Grafana
http://your-vps-ip:3000
Username: admin
Password: (จาก .env file)

# Import dashboards:
# - PostgreSQL Overview
# - Redis Dashboard
# - Docker Container Metrics
# - Node.js Application Metrics
```

## 🔍 Performance Monitoring Commands

### ตรวจสอบ PostgreSQL Performance
```bash
# เข้า PostgreSQL
docker compose exec postgres psql -U n8n -d n8n

# ดู slow queries
SELECT query, mean_time, calls FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;

# ดู connection count
SELECT count(*) FROM pg_stat_activity;

# ดู database size
SELECT pg_size_pretty(pg_database_size('n8n'));

# ดู table sizes
SELECT schemaname,tablename,pg_size_pretty(size) as size
FROM (
    SELECT schemaname,tablename,pg_total_relation_size(schemaname||'.'||tablename) as size
    FROM pg_tables
    ORDER BY size DESC
) as sizes;
```

### ตรวจสอบ Redis Performance
```bash
# เข้า Redis
docker compose exec redis redis-cli

# ดู info
INFO memory
INFO stats
INFO clients

# ดู slow log
SLOWLOG GET 10

# ดู memory usage
MEMORY USAGE key_name
```

### ตรวจสอบ System Performance
```bash
# ดู memory usage
free -h

# ดู disk usage
df -h

# ดู CPU usage
top
htop

# ดู network connections
netstat -tulpn

# ดู Docker resource usage
docker stats --no-stream
```

## 🚨 Performance Alerts

### ตั้งค่า Alerts ใน Prometheus
```yaml
# alerts.yml
groups:
- name: vps_alerts
  rules:
  - alert: HighMemoryUsage
    expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage detected"

  - alert: HighCPUUsage
    expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage detected"

  - alert: PostgreSQLDown
    expr: postgresql_up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "PostgreSQL is down"

  - alert: RedisDown
    expr: redis_up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Redis is down"
```

## 🔧 Tuning สำหรับ Workload เฉพาะ

### สำหรับ Heavy n8n Workflows
```bash
# เพิ่ม memory สำหรับ n8n
docker compose -f docker-compose.high-performance.yml up -d n8n

# ตั้งค่า environment variables
N8N_PAYLOAD_SIZE_MAX=33554432  # 32MB
NODE_OPTIONS=--max_old_space_size=4096
```

### สำหรับ High Database Load
```bash
# เพิ่ม PostgreSQL connections
POSTGRES_MAX_CONNECTIONS=300

# เพิ่ม shared_buffers
POSTGRES_SHARED_BUFFERS=12GB
```

### สำหรับ High Redis Usage
```bash
# เพิ่ม Redis memory
REDIS_MAXMEMORY=8GB

# เปลี่ยน eviction policy
REDIS_MAXMEMORY_POLICY=allkeys-lru
```

## 📊 Benchmark และ Testing

### Database Performance Test
```bash
# ติดตั้ง pgbench
docker compose exec postgres pgbench -i -s 100 n8n

# รัน benchmark
docker compose exec postgres pgbench -c 10 -j 2 -t 1000 n8n
```

### Redis Performance Test
```bash
# ติดตั้ง redis-benchmark
docker compose exec redis redis-benchmark -q -n 100000
```

### n8n Performance Test
```bash
# ทดสอบ webhook performance
curl -X POST https://n8n.yourdomain.com/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## 🛠️ Maintenance Tasks

### Database Maintenance
```bash
# VACUUM และ ANALYZE
docker compose exec postgres psql -U n8n -d n8n -c "VACUUM ANALYZE;"

# ดู bloat
docker compose exec postgres psql -U n8n -d n8n -c "
SELECT schemaname,tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
  pg_stat_get_tuples_returned(c.oid) as tuples_returned,
  pg_stat_get_tuples_fetched(c.oid) as tuples_fetched
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind = 'r'
ORDER BY pg_total_relation_size(c.oid) DESC
LIMIT 20;"
```

### Cache Maintenance
```bash
# ล้าง Redis cache
docker compose exec redis redis-cli FLUSHALL

# ดู Redis memory usage
docker compose exec redis redis-cli INFO memory
```

### Log Rotation
```bash
# ตั้งค่า logrotate
sudo nano /etc/logrotate.d/docker-containers

# เพิ่ม:
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
```

## 🚀 Scaling Options

### Horizontal Scaling
- เพิ่ม n8n instances
- เพิ่ม Redis replicas
- ใช้ PostgreSQL read replicas

### Vertical Scaling
- เพิ่ม RAM
- เพิ่ม CPU cores
- ใช้ NVMe SSD

### Load Balancing
- ใช้ Nginx load balancer
- ตั้งค่า Redis cluster
- ใช้ PostgreSQL connection pooling

---

**หมายเหตุ**: การตั้งค่านี้เหมาะสำหรับ production workloads ที่ต้องการ performance สูง
