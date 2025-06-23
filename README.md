# 🚀 Minecraft Server on AWS with Terraform & Kubernetes 🎮

Your ultimate blueprint to deploy a scalable, automated Minecraft world on AWS. Choose between a simple VM or a full-blown Kubernetes cluster!

<p align="center">
  <a href="https://github.com/sharma987piyush/minecraft-deploy.git" class="btn">
    ⭐ Star on GitHub &rarr;
  </a>
</p>

---

## ✨ Features

* 📦 **Multiple Deployment Options:** Use Terraform for a simple VM, or go pro with Docker & Kubernetes for a containerized setup.

* 🤖 **Fully Automated:** From infrastructure provisioning to application deployment, everything is automated.

* 💾 **Persistent Storage:** Your world is safe! Uses EBS for Terraform or Persistent Volume Claims (PVC) for Kubernetes.

* 🛡️ **Secure & Configurable:** Easily tweak settings through variable files and Kubernetes manifests. Security groups and network policies are baked in.

* 🚀 **CI/CD Ready:** Includes a sample `Jenkinsfile` to automatically build and deploy your server on every code change.

* 📈 **Scalable by Design:** The Kubernetes setup allows for horizontal scaling to handle more players.

---

## 📋 Prerequisites

Before you begin, ensure you have the necessary tools for your chosen deployment path. You won't need all of them, just the ones for the method you choose.

* 🌍 An **AWS Account** with appropriate IAM permissions.

* ⚙️ **Terraform & AWS CLI:** For the simple EC2 instance deployment.

* 🐳 **Docker:** For building the Minecraft server container locally.

* ☸️ **Kubernetes Cluster & `kubectl`:** For deploying the containerized application. An EKS cluster on AWS is a great choice.

* 🤵 **Jenkins:** For automating the build and deploy pipeline.

---

## 🚀 Method 1: The Simple Start (Terraform)

This method provisions a dedicated EC2 instance on AWS. It's perfect for a simple, standalone server to play with friends.

```bash
# 1. Clone the repo and enter the directory
git clone [https://github.com/sharma987piyush/minecraft-deploy.git](https://github.com/sharma987piyush/minecraft-deploy.git)
cd minecraft-deploy

# 2. Initialize, plan, and apply the Terraform configuration
terraform init
terraform plan
terraform apply --auto-approve
```

Terraform will automatically provision all the necessary resources and output the server's IP address when it's done.

---

## 🤖 Method 2: The Pro Setup (CI/CD with Kubernetes)

For a truly robust and scalable setup, this project provides a full CI/CD pipeline using Jenkins to build a Docker container and deploy it to a Kubernetes cluster.

### 🏛️ Project Architecture

The diagram below shows how the components work together in the automated pipeline:

```
Developer   ➡️   Git    ➡️   Jenkins   ➡️   Docker Hub   ➡️   Kubernetes (AWS EKS)
 (push)        (trigger)     (build)        (registry)         (deploy)
    💻           🌿          🤵            🐳                 ☸️
```

### 🔁 CI/CD Pipeline Overview

The automated pipeline brings your Minecraft server to life in four steps:

1.  **✍️ Commit:** A developer pushes a change to the Git repository. This could be updating the server version in the `Dockerfile` or tweaking a Kubernetes manifest. This push automatically triggers the Jenkins pipeline.

2.  **🏗️ Build:** Jenkins wakes up, checks out the latest code, and uses the `Dockerfile` to build a fresh, self-contained Docker image of the Minecraft server.

3.  **📤 Push:** This new image is tagged with a unique build ID and pushed to a container registry like Docker Hub, making it available for deployment.

4.  **🚀 Deploy:** Jenkins securely connects to your Kubernetes cluster and applies the configuration files. Kubernetes sees the new image tag in the `deployment.yaml` and performs a rolling update, launching the new server version with zero downtime.

### 📂 File Content Summary

Here’s a high-level overview of the configuration files that orchestrate this magic:

#### 1. Dockerfile

> **Purpose:** Creates a portable, standalone Minecraft server container.
> This file is the recipe for our server image. It specifies a Java runtime, downloads the official Minecraft server, and configures it to run on startup. Think of it as packaging the server into a neat little box.

#### 2. Kubernetes Manifests (`*.yaml`)

* **`pvc.yaml`**: Guarantees your world's survival by requesting a persistent block of storage from your cloud provider, separate from the server's lifecycle.

* **`deployment.yaml`**: The master plan for your server pods. It defines which Docker image to run, how many replicas to have, and how to perform updates smoothly.

* **`service.yaml`**: Acts as the server's public gateway. It exposes the Minecraft port to the internet via a stable IP address from a cloud load balancer.

* **`hpa.yaml`**: The auto-scaling rule. It tells Kubernetes to automatically add more server pods if the CPU load gets too high.

#### 3. Jenkinsfile

> **Purpose:** The conductor of our CI/CD orchestra.
> This Groovy script defines the entire automation pipeline. It lays out the "Build, Push, Deploy" stages and contains all the commands Jenkins needs to execute at each step.

---

## 🧹 Cleanup

When you're done, destroy your resources to avoid ongoing AWS charges.

* 🔥 **For Terraform:** `terraform destroy --auto-approve`

* 🔥 **For Kubernetes:** `kubectl delete -f .` (from the directory with your YAML files)

> **⚠️ Warning:** These commands are destructive and will permanently delete your server and world data unless backed up. There is no going back!

---

## 🤝 Contributing & Future Ideas

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/sharma987piyush/minecraft-deploy/issues). Some ideas for the future include:

* 📊 Adding monitoring and alerts with Prometheus/Grafana.

* 🤖 Implementing true player-count-based scaling.

* 🗄️ Setting up automated world backups to S3.

---

## 📜 License

This project is licensed under the MIT License.

<p align="center">
  Crafted with ❤️ and ☕ in India.
</p>
