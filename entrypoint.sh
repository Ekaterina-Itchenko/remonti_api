#!/bin/bash
set -e

echo "Ожидание доступности базы данных..."
# база данных (сервис db) станет рабочей
until nc -z db 5432; do
  echo "База данных не готова, ожидаем..."
  sleep 1
done
echo "База данных доступна."

echo "Применяем миграции..."
# изменён путь к manage.py
python ./remonti_app/manage.py migrate --noinput

echo "Создаём суперпользователя (если его ещё нет)..."
# тоже
python ./remonti_app/manage.py shell -c "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
exists = User.objects.filter(username='$DJANGO_SUPERUSER_USERNAME').exists(); \
print('Суперпользователь существует:', exists); \
exit(0) if exists else User.objects.create_superuser('$DJANGO_SUPERUSER_USERNAME', '$DJANGO_SUPERUSER_EMAIL', '$DJANGO_SUPERUSER_PASSWORD')"

# удалить на проде
echo "Создаём 5 дополнительных пользователей..."
python ./remonti_app/manage.py shell -c "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
not User.objects.filter(username='user1').exists() and User.objects.create_user(username='user1', email='user1@example.com', password='password'); \
not User.objects.filter(username='user2').exists() and User.objects.create_user(username='user2', email='user2@example.com', password='password'); \
not User.objects.filter(username='user3').exists() and User.objects.create_user(username='user3', email='user3@example.com', password='password'); \
not User.objects.filter(username='user4').exists() and User.objects.create_user(username='user4', email='user4@example.com', password='password'); \
not User.objects.filter(username='user5').exists() and User.objects.create_user(username='user5', email='user5@example.com', password='password'); \
print('Дополнительные пользователи созданы.')"

# запуск основной команды
exec "$@"
