FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY pyproject.toml poetry.lock /app/

RUN pip install --upgrade pip && pip install poetry

RUN pip install psycopg2-binary

RUN poetry config virtualenvs.create false

RUN poetry install --no-root


COPY . /app

EXPOSE 8000

# для проверки доступности базы данных
RUN apt-get update && apt-get install -y netcat-openbsd

# права на выполнение и выполнение
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# скрипт в качестве точки входа
ENTRYPOINT ["/entrypoint.sh"]

# команда запуска. Для разработки можно запустить runserver, для прод – gunicorn.
# CMD ["gunicorn", "remonti_app.wsgi:application", "--bind", "0.0.0.0:8000"]

CMD ["python", "./remonti_app/manage.py", "runserver", "0.0.0.0:8000"]
