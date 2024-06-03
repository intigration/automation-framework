FROM nikolaik/python-nodejs:latest

LABEL Name="Automted Test Framwork" Version=1.4.2


WORKDIR /
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN npm install -g newman newman-reporter-html newman-reporter-htmlextra


# COPY . ./app

# EXPOSE 5000

# WORKDIR /app

CMD ["./dev.sh"]

# CMD ["gunicorn", "-b", "0.0.0.0:5000", "run:app"]

