
# Chainguard Python Image Security Demo

This demo showcases the security benefits of using Chainguard's minimal, secure container images compared to standard, general-purpose images.

We build three functionally identical Python web applications, one based on a standard Debian image (`python:3.14-slim-bookworm`), another based on a standard Debian full image (`python:latest`) and the last on a Chainguard Python image (`cgr.dev/chainguard/python`). We then use the `grype` vulnerability scanner to inspect all three images and embed the results into the web application served by each container.

The result is a clear, visual demonstration of the reduced attack surface and improved security posture provided by Chainguard images.

![Alt text](images/image.png)

## Prerequisites

Before you begin, ensure you have the following tools installed:

*   **Docker:** [Installation Guide](https://docs.docker.com/engine/install/)
*   **Grype:** [Installation Guide](https://github.com/anchore/grype)
*   **Cosign:** [Installation Guide](https://github.com/sigstore/cosign)

## How to Run the Demo

1.  **Make the script executable:**

    ```bash
    chmod +x build_and_run.sh
    ```

2.  **Run the build and scan script:**

    ```bash
    ./build_and_run.sh
    ```

    This script will:
    *   Build the Debian-based Docker image.
    *   Scan it with `grype` and save the report.
    *   Build the Chainguard-based Docker image.
    *   Scan it with `grype` and save the report.
    *   Run 3 python base containers. A debian Slim, Debian Full & Chainguard.

3.  **The below commands are in the script to run the containers:**

    *   **Debian Container (on port 8080):**

        ```bash
        docker run -d -p 8080:8080 --rm -v $(pwd)/reports/grype-report-debian.json:/app/grype-report.json:ro --name python-debian-demo python-debian-demo
        ```

    *   **Chainguard Container (on port 8081):**

        ```bash
        docker run -d -p 8081:8080 --rm -v $(pwd)/reports/grype-report-chainguard.json:/app/grype-report.json:ro --name python-chainguard-demo python-chainguard-demo
        ```

    *   **Debian Full Container (on port 8082):**

        ```bash
        docker run -d -p 8082:8080 --rm -v $(pwd)/reports/grype-report-debian-full.json:/app/grype-report.json:ro --name python-debian-full-demo python-debian-full-demo
        ```

4.  **View the Results:**

    *   Open your web browser to [http://localhost:8080](http://localhost:8080) to see the vulnerability report for the **Debian-based image**.
    *   Open a new tab and navigate to [http://localhost:8081](http://localhost:8081) to see the vulnerability report for the **Chainguard image**.
    *   Open a new tab and navigate to [http://localhost:8082](http://localhost:8082) to see the vulnerability report for the **Debian Full image**.

5. **Bonus Points:**

    a)  stop the Debian slim instance and log into the bash shell. 
    ```bash
    docker stop python-debian-demo
    ```

    *   restart the instance with **-it** and bash to execute bash in realtime. 
    ```bash
    docker run -it -p 8080:8080 --rm -v $(pwd)/reports/grype-report-debian.json:/app/grype-report.json:ro --name python-debian-demo python-debian-demo bash
    ```

    b)  Chainguard Containers are signed using Sigstore, and you can check the included signatures using cosign.
    ```bash
    cosign verify --certificate-oidc-issuer=https://token.actions.githubusercontent.com --certificate-identity=https://github.com/chainguard-images/images/.github/workflows/release.yaml@refs/heads/main cgr.dev/chainguard/python | jq
    ```

    c)  Review contents of the SBOM 
    ```bash
    cosign download attestation --platform=linux/amd64 --predicate-type=https://spdx.dev/Document cgr.dev/chainguard/python | jq -r .payload | base64 -d | jq .predicate
    ```

    d)  Verify the SBOM **note - --type specified below**
    ```bash
    cosign verify-attestation --type https://spdx.dev/Document --certificate-oidc-issuer=https://token.actions.githubusercontent.com --certificate-identity=https://github.com/chainguard-images/images/.github/workflows/release.yaml@refs/heads/main cgr.dev/chainguard/python    ```

6.  **Stop the containers:**

    When you are finished, you can stop the containers with the following commands:

    ```bash
    docker stop python-debian-demo
    docker stop python-chainguard-demo
    docker stop python-debian-full-demo
    ```

## Expected Outcome

You will observe a stark difference in the number of vulnerabilities reported.

*   The **Debian-based image** will likely show a significant number of vulnerabilities (low, medium, high, and critical).
*   The **Chainguard image** will show **zero or near-zero** vulnerabilities.

This powerfully illustrates the value of building applications on a minimal, secure foundation. By removing unnecessary packages, libraries, and shells, Chainguard images dramatically reduce the attack surface, leading to a more secure and compliant software supply chain.
