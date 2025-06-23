<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🚀 Minecraft Server on AWS with Terraform & Kubernetes 🎮</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #111827; /* bg-gray-900 */
            color: #d1d5db; /* text-gray-300 */
        }
        .container {
            max-width: 800px;
            margin: auto;
        }
        h1, h2, h3 {
            color: #f9fafb; /* text-gray-50 */
            font-weight: 700;
        }
        h1 {
            font-size: 2.5rem;
            letter-spacing: -0.05em;
        }
        h2 {
            font-size: 1.75rem;
            margin-top: 2.5rem;
            margin-bottom: 1rem;
            border-bottom: 2px solid #374151; /* border-gray-700 */
            padding-bottom: 0.5rem;
        }
        h3 {
            font-size: 1.25rem;
            margin-top: 1.5rem;
            margin-bottom: 0.5rem;
        }
        p, li {
            line-height: 1.6;
        }
        a {
            color: #60a5fa; /* text-blue-400 */
            text-decoration: none;
            transition: color 0.3s ease;
        }
        a:hover {
            color: #93c5fd; /* text-blue-300 */
        }
        code.inline-code {
            background-color: #374151; /* bg-gray-700 */
            color: #e5e7eb; /* text-gray-200 */
            padding: 0.2em 0.4em;
            margin: 0;
            font-size: 85%;
            border-radius: 6px;
        }
        pre {
            background-color: #1f2937; /* bg-gray-800 */
            border: 1px solid #374151; /* border-gray-700 */
            color: #d1d5db; /* text-gray-300 */
            padding: 1.5rem;
            border-radius: 8px;
            overflow-x: auto;
            white-space: pre-wrap;
            word-wrap: break-word;
            font-family: 'Courier New', Courier, monospace;
        }
        .emoji {
            display: inline-block;
            vertical-align: middle;
        }
        .btn {
            display: inline-block;
            background-color: #3b82f6; /* bg-blue-600 */
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            transition: background-color 0.3s ease;
        }
        .btn:hover {
            background-color: #2563eb; /* bg-blue-700 */
        }
        .note {
            background-color: #1f2937; /* bg-gray-800 */
            border-left: 4px solid #f59e0b; /* border-amber-500 */
            padding: 1rem;
            margin: 1.5rem 0;
            border-radius: 0 8px 8px 0;
        }
        .warn-note {
             background-color: #1f2937; /* bg-gray-800 */
            border-left: 4px solid #ef4444; /* border-red-500 */
            padding: 1rem;
            margin: 1.5rem 0;
            border-radius: 0 8px 8px 0;
        }
    </style>
</head>
<body class="p-4 sm:p-8">
    <div class="container">
        <!-- Header Section -->
        <div class="text-center py-8">
            <h1 class="mb-4">
                <span class="emoji">🚀</span> Minecraft Server on AWS with Terraform & Kubernetes <span class="emoji">🎮</span>
            </h1>
            <p class="text-xl text-gray-400">
                Your ultimate blueprint to deploy a scalable, automated Minecraft world on AWS. Choose between a simple VM or a full-blown Kubernetes cluster!
            </p>
            <div class="mt-8">
                <a href="https://github.com/sharma987piyush/minecraft-deploy.git" class="btn">
                    ⭐ Star on GitHub &rarr;
                </a>
            </div>
        </div>

        <!-- Features Section -->
        <h2>✨ Features</h2>
        <ul class="list-disc list-inside space-y-2">
            <li><span class="emoji">📦</span> <strong>Multiple Deployment Options:</strong> Use Terraform for a simple VM, or go pro with Docker & Kubernetes for a containerized setup.</li>
            <li><span class="emoji">🤖</span> <strong>Fully Automated:</strong> From infrastructure provisioning to application deployment, everything is automated.</li>
            <li><span class="emoji">💾</span> <strong>Persistent Storage:</strong> Your world is safe! Uses EBS for Terraform or Persistent Volume Claims (PVC) for Kubernetes.</li>
            <li><span class="emoji">🛡️</span> <strong>Secure & Configurable:</strong> Easily tweak settings through variable files and Kubernetes manifests. Security groups and network policies are baked in.</li>
            <li><span class="emoji">🚀</span> <strong>CI/CD Ready:</strong> Includes a sample <code class="inline-code">Jenkinsfile</code> to automatically build and deploy your server on every code change.</li>
            <li><span class="emoji">📈</span> <strong>Scalable by Design:</strong> The Kubernetes setup allows for horizontal scaling to handle more players.</li>
        </ul>

        <!-- Prerequisites Section -->
        <h2>📋 Prerequisites</h2>
        <p>Before you begin, ensure you have the necessary tools for your chosen deployment path. You won't need all of them, just the ones for the method you choose.</p>
        <ul class="list-disc list-inside space-y-2 mt-4">
            <li><span class="emoji">🌍</span> An <strong>AWS Account</strong> with appropriate IAM permissions.</li>
            <li><span class="emoji">⚙️</span> <strong>Terraform & AWS CLI:</strong> For the simple EC2 instance deployment.</li>
            <li><span class="emoji">🐳</span> <strong>Docker:</strong> For building the Minecraft server container locally.</li>
            <li><span class="emoji">☸️</span> <strong>Kubernetes Cluster & <code class="inline-code">kubectl</code>:</strong> For deploying the containerized application. An EKS cluster on AWS is a great choice.</li>
            <li><span class="emoji">🤵</span> <strong>Jenkins:</strong> For automating the build and deploy pipeline.</li>
        </ul>

        <!-- Terraform Deployment Section -->
        <h2>🚀 Method 1: The Simple Start (Terraform)</h2>
        <p>This method provisions a dedicated EC2 instance on AWS. It's perfect for a simple, standalone server to play with friends.</p>
        <pre><code># 1. Clone the repo and enter the directory
git clone https://github.com/sharma987piyush/minecraft-deploy.git
cd minecraft-deploy

# 2. Initialize, plan, and apply the Terraform configuration
terraform init
terraform plan
terraform apply --auto-approve
</code></pre>
        <p class="mt-2">Terraform will automatically provision all the necessary resources and output the server's IP address when it's done.</p>


        <!-- Advanced Deployments Section -->
        <h2>🤖 Method 2: The Pro Setup (CI/CD with Kubernetes)</h2>
        <p>For a truly robust and scalable setup, this project provides a full CI/CD pipeline using Jenkins to build a Docker container and deploy it to a Kubernetes cluster.</p>

        <h3>🏛️ Project Architecture</h3>
        <p>The diagram below shows how the components work together in the automated pipeline:</p>
        <pre>
Developer   &rarr;   Git    &rarr;   Jenkins   &rarr;   Docker Hub   &rarr;   Kubernetes (AWS EKS)
 (push)        (trigger)     (build)        (registry)         (deploy)
    💻           🌿          🤵            🐳                 ☸️
        </pre>
        
        <h3>🔁 CI/CD Pipeline Overview</h3>
        <p>The automated pipeline brings your Minecraft server to life in four steps:</p>
        <ol class="list-decimal list-inside space-y-3 mt-4">
            <li><strong>✍️ Commit:</strong> A developer pushes a change to the Git repository. This could be updating the server version in the <code class="inline-code">Dockerfile</code> or tweaking a Kubernetes manifest. This push automatically triggers the Jenkins pipeline.</li>
            <li><strong>🏗️ Build:</strong> Jenkins wakes up, checks out the latest code, and uses the <code class="inline-code">Dockerfile</code> to build a fresh, self-contained Docker image of the Minecraft server.</li>
            <li><strong>📤 Push:</strong> This new image is tagged with a unique build ID and pushed to a container registry like Docker Hub, making it available for deployment.</li>
            <li><strong>🚀 Deploy:</strong> Jenkins securely connects to your Kubernetes cluster and applies the configuration files. Kubernetes sees the new image tag in the <code class="inline-code">deployment.yaml</code> and performs a rolling update, launching the new server version with zero downtime.</li>
        </ol>
        
        <h3>📂 File Content Summary</h3>
        <p>Here’s a high-level overview of the configuration files that orchestrate this magic:</p>

        <h4>1. Dockerfile</h4>
        <div class="note">
            <p><strong>Purpose:</strong> Creates a portable, standalone Minecraft server container.</p>
            This file is the recipe for our server image. It specifies a Java runtime, downloads the official Minecraft server, and configures it to run on startup. Think of it as packaging the server into a neat little box.
        </div>

        <h4>2. Kubernetes Manifests (<code class="inline-code">*.yaml</code>)</h4>
        <ul class="list-disc list-inside space-y-3 mt-4">
            <li><code class="inline-code">pvc.yaml</code>: Guarantees your world's survival by requesting a persistent block of storage from your cloud provider, separate from the server's lifecycle.</li>
            <li><code class="inline-code">deployment.yaml</code>: The master plan for your server pods. It defines which Docker image to run, how many replicas to have, and how to perform updates smoothly.</li>
            <li><code class="inline-code">service.yaml</code>: Acts as the server's public gateway. It exposes the Minecraft port to the internet via a stable IP address from a cloud load balancer.</li>
            <li><code class="inline-code">hpa.yaml</code>: The auto-scaling rule. It tells Kubernetes to automatically add more server pods if the CPU load gets too high, though true player-based scaling is more advanced.</li>
        </ul>

        <h4>3. Jenkinsfile</h4>
        <div class="note">
            <p><strong>Purpose:</strong> The conductor of our CI/CD orchestra.</p>
            This Groovy script defines the entire automation pipeline. It lays out the "Build, Push, Deploy" stages and contains all the commands Jenkins needs to execute at each step.
        </div>

        <!-- Cleanup Section -->
        <h2>🧹 Cleanup</h2>
        <p>When you're done, destroy your resources to avoid ongoing AWS charges.</p>
        <ul class="list-disc list-inside space-y-2 mt-4">
            <li><span class="emoji">🔥</span> <strong>For Terraform:</strong> <code class="inline-code">terraform destroy --auto-approve</code></li>
            <li><span class="emoji">🔥</span> <strong>For Kubernetes:</strong> <code class="inline-code">kubectl delete -f .</code> (from the directory with your YAML files)</li>
        </ul>
        <div class="warn-note">
            <p><strong>Warning:</strong> These commands are destructive and will permanently delete your server and world data unless backed up. There is no going back!</p>
        </div>

        <!-- Contributing & License -->
        <h2>🤝 Contributing & Future Ideas</h2>
        <p>Contributions, issues, and feature requests are welcome! Feel free to check the <a href="https://github.com/sharma987piyush/minecraft-deploy/issues" target="_blank">issues page</a>. Some ideas for the future include:</p>
        <ul class="list-disc list-inside space-y-2 mt-4">
            <li>📊 Adding monitoring and alerts with Prometheus/Grafana.</li>
            <li>🤖 Implementing true player-count-based scaling.</li>
            <li>🗄️ Setting up automated world backups to S3.</li>
        </ul>

        <h2>📜 License</h2>
        <p>This project is licensed under the MIT License.</p>
        
        <div class="text-center text-gray-500 pt-12 pb-4">
            <p>Crafted with ❤️ and ☕ in India.</p>
        </div>
    </div>
</body>
</html>
