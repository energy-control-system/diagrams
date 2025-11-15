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

            # Архитектурные кванты
            inspectionsQuant = container "Inspections Quant" "Архитектурный квант проверок" {
                tags "Quant"

                userService = component "User Service" "Управление пользователями и авторизация" "NodeJS" "Microservice"
                brigadeService = component "Brigade Service" "Управление бригадами и их составом" "Go" "Microservice"
                subscriberService = component "Subscriber Service" "Управление абонентами и их данными" "Go" "Microservice"
                taskService = component "Task Service" "Управление задачами и их жизненным циклом" "Go" "Microservice"
                inspectionService = component "Inspection Service" "Проведение и фиксация результатов проверок" "Go" "Microservice"
                fileService = component "File Service" "Централизованное хранение файлов" "Go" "Microservice"
                analyticsService = component "Analytics Service" "Генерация отчетов и аналитика" "Go" "Microservice"
                analyzerService = component "Photo Analyzer Service" "Анализ фотографий на искажения" "Python" "Microservice"

                usersDB = component "Users Database" "База данных пользователей" "PostgreSQL" "Database"
                brigadesDB = component "Brigades Database" "База данных бригад" "PostgreSQL" "Database"
                subscribersDB = component "Subscribers Database" "База данных абонентов" "PostgreSQL" "Database"
                tasksDB = component "Tasks Database" "База данных задач" "PostgreSQL" "Database"
                inspectionsDB = component "Inspections Database" "База данных проверок" "PostgreSQL" "Database"
                filesDB = component "Files Database" "Метаданные файлов" "PostgreSQL" "Database"
                reportsDB = component "Reports Database" "База данных отчетов" "PostgreSQL" "Database"
                analyticsDB = component "Analytics Database" "База данных аналитики" "Clickhouse" "Database"

                objectStorage = component "Object Storage" "Хранилище объектов" "MinIO" "Storage"

                messageBroker = component "Message Broker" "Асинхронное взаимодействие между сервисами" "Kafka" "MessageBroker"
            }
        }

        # Связи между людьми и системой
        inspector -> mobileApp "Использует для проведения проверок"
        dispatcher -> webPortal "Управляет бригадами и задачами"
        specialist -> webPortal "Работает с данными абонентов"

        # Связи клиентских приложений с API Gateway
        mobileApp -> apiGateway "Отправляет API запросы" "HTTPS/REST"
        webPortal -> apiGateway "Отправляет API запросы" "HTTPS/REST"

        # Связи API Gateway с архитектурными квантами
        apiGateway -> inspectionsQuant "Маршрутизирует запросы" "HTTP/REST"

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
        taskService -> messageBroker "Публикует события задач и подписан на события проверок" "Kafka"
        inspectionService -> messageBroker "Публикует события проверок и подписан на события задач" "Kafka"
        analyticsService -> messageBroker "Подписан на события задач" "Kafka"
        brigadeService -> messageBroker "Подписан на события задач" "Kafka"
        subscriberService -> messageBroker "Подписан на события проверок" "Kafka"

        # Связи микросервисов с базами данных
        userService -> usersDB "Чтение/запись" "SQL"
        brigadeService -> brigadesDB "Чтение/запись" "SQL"
        subscriberService -> subscribersDB "Чтение/запись" "SQL"
        taskService -> tasksDB "Чтение/запись" "SQL"
        inspectionService -> inspectionsDB "Чтение/запись" "SQL"
        fileService -> filesDB "Чтение/запись" "SQL"
        fileService -> objectStorage "Чтение/запись" "HTTP"
        analyticsService -> reportsDB "Чтение/запись" "SQL"
        analyticsService -> analyticsDB "Чтение/запись" "SQL"

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

        # Диаграмма компонентов
        component inspectionsQuant "InspectionsQuant" {
            include *
            autoLayout
            title "Диаграмма компонентов архитектурного кванта проверок"
            description "Показывает внутреннюю архитектуру кванта проверок"
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

            element "Quant" {
                shape Ellipse
            }

            element "Microservice" {
                shape Hexagon
                background #1168bd
                color #ffffff
            }

            element "MessageBroker" {
                shape Pipe
                background #ff9500
                color #ffffff
            }

            element "Database" {
                shape Cylinder
                background #438dd5
                color #ffffff
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
