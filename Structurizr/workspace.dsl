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
            userService = container "User Management Service" "Управление пользователями и авторизация" "NodeJS" "Microservice"
            brigadeService = container "Brigade Management Service" "Управление бригадами и их составом" "NodeJS" "Microservice"
            subscriberService = container "Subscriber Management Service" "Управление абонентами и их данными" "NodeJS" "Microservice"
            taskService = container "Task Management Service" "Управление задачами и их жизненным циклом" "Go" "Microservice"
            inspectionService = container "Inspection Service" "Проведение и фиксация результатов проверок" "Go" "Microservice"
            fileService = container "File Storage Service" "Централизованное хранение файлов" "Go" "Microservice"
            analyticsService = container "Analytics Service" "Генерация отчетов и аналитика" "Go" "Microservice"
            analyzerService = container "Photo Analyzer Service" "Анализ фотографий на искажения" "Python" "Microservice"

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
        brigadeService -> userService "Получает информацию об инспекторах" "HTTP/REST"
        inspectionService -> fileService "Сохраняет фотографии и акты" "HTTP/REST"
        analyticsService -> fileService "Сохраняет отчеты" "HTTP/REST"
        inspectionService -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        inspectionService -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        analyticsService -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        analyticsService -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        analyticsService -> taskService "Получает информацию о задачах" "HTTP/REST"

        # Асинхронные взаимодействия через Message Broker
        taskService -> messageBroker "Публикует события задач и слушает события проверок" "Kafka"
        inspectionService -> messageBroker "Публикует события проверок и слушает события задач" "Kafka"
        analyticsService -> messageBroker "Слушает события проверок" "Kafka"
        brigadeService -> messageBroker "Слушает события задач" "Kafka"
        subscriberService -> messageBroker "Слушает события проверок" "Kafka"

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
