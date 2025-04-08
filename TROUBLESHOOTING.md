## **Troubleshooting**

### **1. Startup Script Issues**
If the startup script fails, check the logs on VM shell:
```bash
sudo journalctl -u google-startup-scripts.service
```

### **2. Kestra Not Starting**
Ensure Docker is installed and running on the VM. Restart the Kestra service if necessary:
```bash
docker_down
docker_up
```

---



---