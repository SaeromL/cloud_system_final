<p>When I run this app locally (http://localhost:8080), the app would look like this:</p>

<img width="624" alt="image" src="https://github.com/user-attachments/assets/6d993dd7-0a08-436f-b2dd-7fb21ddec0b6"><br><br>

<p>And then I packaged this java program, created Dockerfile and then uploaded this java project in Cloud9 to test the Docker image locally.</p>
<p>docker build -t task-manager .</p>
<img width="369" alt="image" src="https://github.com/user-attachments/assets/596695a7-2aaf-4c3a-bff3-58f802a78671"><br><br>
<p>docker images</p>
<img width="408" alt="image" src="https://github.com/user-attachments/assets/42c218f7-72d6-403b-86bc-b19bbb634193"><br><br>
<p>docker run -it -d task-manager</p>
<img width="547" alt="image" src="https://github.com/user-attachments/assets/a4d86bba-a985-43a2-a106-5a5851e3412e"><br><br>
<p>curl http://172.17.0.2:80</p>
<img width="543" alt="image" src="https://github.com/user-attachments/assets/a15ad5c7-3a08-4ac1-b587-db5409b28a0c"><br><br>

<p>Since this app is only available to cloud 9 container 67ce047da82f, make the container to listen to port 80. </p>
<img width="648" alt="image" src="https://github.com/user-attachments/assets/8fd27b58-5c91-48e8-a30a-ee0671dbff44"><br><br>

<p>And update the inbound rules from security group.</p>
<img width="406" alt="image" src="https://github.com/user-attachments/assets/2dd52b24-6294-4572-842a-d5d3f2a29798"><br><br>

<p>Now this app is available via web browser.</p>
<img width="425" alt="image" src="https://github.com/user-attachments/assets/f357351f-c85c-42ba-9ee5-deda66750dec">
