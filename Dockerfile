#
# This repo isn't a development heavy place but we have some stuff 
# that is of interest to run. Starting with some jupyter notebooks
# so you can do:
# 	docker built -t cam .
#	docker run -p 8888:888 cam
#

# Use the Jupyter Notebook minimal image as the base image
FROM jupyter/minimal-notebook

# Set the working directory to /app
WORKDIR /app

# Copy the requirements.txt file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the project files to the container
COPY . .

# Expose the default Jupyter Notebook port (8888)
EXPOSE 8888

# Start the Jupyter Notebook server
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
