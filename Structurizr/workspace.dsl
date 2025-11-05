workspace "Система контроля и анализа потребления электроэнергии" {
    model {
        # Определяем людей (акторов)
        inspector = person "Энергоинспектор" "Проводит проверки объектов энергоснабжения" "Inspector"
        dispatcher = person "Диспетчер" "Управляет бригадами и назначает задачи" "Dispatcher"
        specialist = person "Специалист по работе с абонентами" "Управляет данными абонентов и договорами" "Specialist"

        # Внешние системы
        mapsApi = softwareSystem "Maps API" "Картографические сервисы для построения маршрутов" "External"

        # Основная система
        energyControlSystem = softwareSystem "Система контроля и анализа потребления электроэнергии" {
            # Клиентские приложения
            mobileApp = container "Mobile App" "Мобильное приложение для инспекторов" "React/TypeScript" "MobileApp"
            webPortal = container "Web Portal" "Веб-портал для диспетчеров и специалистов" "React/TypeScript" "WebApp"

            # API Gateway
            apiGateway = container "API Gateway" "Единая точка входа для всех API запросов" "NodeJS" "ApiGateway"

            # Микросервисы
            userService = container "User Service" "Управление пользователями и авторизация" "NodeJS" "Microservice"
            brigadeService = container "Brigade Service" "Управление бригадами и их составом" "Go" "Microservice"
            subscriberService = container "Subscriber Service" "Управление абонентами и их данными" "Go" "Microservice"
            taskService = container "Task Service" "Управление задачами и их жизненным циклом" "Go" "Microservice"
            inspectionService = container "Inspection Service" "Проведение и фиксация результатов проверок" "Go" "Microservice"
            fileService = container "File Service" "Централизованное хранение файлов" "Go" "Microservice"
            analyticsService = container "Analytics Service" "Генерация отчетов и аналитика" "Go" "Microservice"
            analyzerService = container "Photo Analyzer Service" "Анализ фотографий на искажения" "Python" "Microservice"

            # Базы данных
            usersDB = container "Users Database" "База данных пользователей" "PostgreSQL" "Database"
            brigadesDB = container "Brigades Database" "База данных бригад" "PostgreSQL" "Database"
            subscribersDB = container "Subscribers Database" "База данных абонентов" "PostgreSQL" "Database"
            tasksDB = container "Tasks Database" "База данных задач" "PostgreSQL" "Database"
            inspectionsDB = container "Inspections Database" "База данных проверок" "PostgreSQL" "Database"
            filesDB = container "Files Database" "Метаданные файлов" "PostgreSQL" "Database"
            reportsDB = container "Reports Database" "База данных отчетов" "PostgreSQL" "Database"
            analyticsDB = container "Analytics Database" "База данных аналитики" "Clickhouse" "Database"

            # Хранилища
            filesStorage = container "Files Storage" "Хранилище файлов" "MinIO" "Storage"

            # Брокер сообщений
            messageBroker = container "Message Broker" "Асинхронное взаимодействие между сервисами" "Kafka" "MessageBroker"
        }

        # Связи между людьми и системой
        inspector -> mobileApp "Использует для проведения проверок"
        dispatcher -> webPortal "Управляет бригадами и задачами"
        specialist -> webPortal "Работает с данными абонентов"

        # Связи клиентских приложений с API Gateway
        mobileApp -> apiGateway "Отправляет API запросы" "HTTPS/REST"
        webPortal -> apiGateway "Отправляет API запросы" "HTTPS/REST"

        # Связи API Gateway с микросервисами
        apiGateway -> userService "Маршрутизирует запросы аутентификации" "HTTP/REST"
        apiGateway -> brigadeService "Маршрутизирует запросы управления бригадами" "HTTP/REST"
        apiGateway -> subscriberService "Маршрутизирует запросы управления абонентами" "HTTP/REST"
        apiGateway -> taskService "Маршрутизирует запросы управления задачами" "HTTP/REST"
        apiGateway -> inspectionService "Маршрутизирует запросы проверок" "HTTP/REST"
        apiGateway -> fileService "Маршрутизирует запросы работы с файлами" "HTTP/REST"
        apiGateway -> analyticsService "Маршрутизирует запросы аналитики" "HTTP/REST"

        # Взаимодействие микросервисов
        inspectionService -> analyzerService "Проверяет фото приборов учета" "HTTP/REST"
        inspectionService -> fileService "Сохраняет фотографии и акты" "HTTP/REST"
        inspectionService -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        inspectionService -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        inspectionService -> taskService "Получает информацию о задачах" "HTTP/REST"
        analyticsService -> fileService "Сохраняет отчеты" "HTTP/REST"
        analyticsService -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        analyticsService -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        analyticsService -> inspectionService "Получает информацию о проверках" "HTTP/REST"
        brigadeService -> userService "Получает информацию об инспекторах" "HTTP/REST"
        subscriberService -> taskService "Получает информацию о задачах" "HTTP/REST"

        # Асинхронные взаимодействия через Message Broker
        taskService -> messageBroker "Публикует события задач и слушает события проверок" "Kafka"
        inspectionService -> messageBroker "Публикует события проверок и слушает события задач" "Kafka"
        analyticsService -> messageBroker "Слушает события задач" "Kafka"
        brigadeService -> messageBroker "Слушает события задач" "Kafka"
        subscriberService -> messageBroker "Слушает события проверок" "Kafka"

        # Связи микросервисов с базами данных
        userService -> usersDB "Читает и записывает данные пользователей" "SQL"
        brigadeService -> brigadesDB "Читает и записывает данные бригад" "SQL"
        subscriberService -> subscribersDB "Читает и записывает данные абонентов" "SQL"
        taskService -> tasksDB "Читает и записывает данные задач" "SQL"
        inspectionService -> inspectionsDB "Читает и записывает данные проверок" "SQL"
        fileService -> filesDB "Читает и записывает метаданные файлов" "SQL"
        fileService -> filesStorage "Читает и записывает файлы" "HTTP"
        analyticsService -> reportsDB "Читает и записывает данные отчетов" "SQL"
        analyticsService -> analyticsDB "Читает и записывает аналитические данные" "SQL"

        # Связи с внешними системами
        mobileApp -> mapsApi "Получает картографические данные" "HTTPS/REST"
    }

    views {
        # Контекстная диаграмма системы
        systemContext energyControlSystem "SystemContext" {
            include *
            autoLayout
            title "Контекстная диаграмма системы"
            description "Показывает основных пользователей системы и внешние интеграции"
        }

        # Диаграмма контейнеров
        container energyControlSystem "Containers" {
            include *
            autoLayout
            title "Диаграмма контейнеров"
            description "Показывает верхнеуровневую архитектуру системы"
        }

        theme default

        # Стили для элементов
        styles {
            element "External" {
                background #999999
            }

            element "MobileApp" {
                shape MobileDevicePortrait
            }

            element "WebApp" {
                shape WebBrowser
            }

            element "ApiGateway" {
                background #ff6b35
            }

            element "Microservice" {
                shape Hexagon
                background #1168bd
            }

            element "MessageBroker" {
                shape Pipe
                background #ff9500
            }

            element "Database" {
                shape Cylinder
                background #438dd5
            }

            element "Storage" {
                shape Folder
                background #85bbf0
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}
