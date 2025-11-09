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
            userService = container "User Service" "Управление пользователями и авторизация" "NodeJS" "Microservice" {
                authController = component "Auth Controller" "REST API для аутентификации и авторизации"
                userController = component "User Controller" "REST API для управления пользователями"

                authBusinessLogic = component "Auth Business Logic" "Бизнес-логика аутентификации и авторизации"
                userBusinessLogic = component "User Business Logic" "Бизнес-логика управления пользователями"

                userRepository = component "User Repository" "Доступ к данным пользователей"
            }

            brigadeService = container "Brigade Service" "Управление бригадами и их составом" "Go" "Microservice" {
                brigadeRouter = component "Brigade Router" "REST API для управления бригадами"

                brigadeBusinessLogic = component "Brigade Business Logic" "Бизнес-логика управления бригадами"

                brigadeRepository = component "Brigade Repository" "Доступ к данным бригад"
            }

            subscriberService = container "Subscriber Service" "Управление абонентами и их данными" "Go" "Microservice" {
                contractRouter = component "Contract Router" "REST API для управления договорами"
                objectRouter = component "Object Router" "REST API для управления объектами проверки"
                registryRouter = component "Registry Router" "REST API для управления реестром"
                subscriberRouter = component "Subscriber Router" "REST API для управления абонентами"

                contractBusinessLogic = component "Contract Business Logic" "Бизнес-логика управления договорами"
                objectBusinessLogic = component "Object Business Logic" "Бизнес-логика управления объектами проверки"
                registryBusinessLogic = component "Registry Business Logic" "Бизнес-логика управления реестром"
                subscriberBusinessLogic = component "Subscriber Business Logic" "Бизнес-логика управления абонентами"

                contractRepository = component "Contract Repository" "Доступ к данным договоров"
                objectRepository = component "Object Repository" "Доступ к данным объектов проверки"
                subscriberRepository = component "Subscriber Repository" "Доступ к данным абонентов"
            }

            taskService = container "Task Service" "Управление задачами и их жизненным циклом" "Go" "Microservice" {
                taskRouter = component "Task Router" "REST API для управления задачами"

                taskBusinessLogic = component "Task Business Logic" "Бизнес-логика управления задачами"

                taskRepository = component "Task Repository" "Доступ к данным задач"
            }

            inspectionService = container "Inspection Service" "Проведение и фиксация результатов проверок" "Go" "Microservice" {
                inspectionRouter = component "Inspection Router" "REST API для управления проверками"

                inspectionBusinessLogic = component "Inspection Business Logic" "Бизнес-логика управления проверками"

                inspectionRepository = component "Inspection Repository" "Доступ к данным проверок"
            }

            fileService = container "File Service" "Централизованное хранение файлов" "Go" "Microservice" {
                fileRouter = component "File Router" "REST API для управления файлами"

                fileBusinessLogic = component "File Business Logic" "Бизнес-логика управления файлами"

                fileRepository = component "File Repository" "Доступ к метаданным файлов"
                fileStorage = component "File Storage" "Доступ к данным файлов"
            }

            analyticsService = container "Analytics Service" "Генерация отчетов и аналитика" "Go" "Microservice" {
                analyticsRouter = component "Analytics Router" "REST API аналитики"

                analyticsBusinessLogic = component "Analytics Business Logic" "Бизнес-логика аналитики"
                cronService = component "Cron Service" "Сервис автоматических задач"

                analyticsRepository = component "Analytics Repository" "Доступ к данным аналитики"
            }

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
            objectStorage = container "Object Storage" "Хранилище объектов" "MinIO" "Storage"

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
        apiGateway -> userService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> brigadeService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> subscriberService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> taskService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> inspectionService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> fileService "Маршрутизирует запросы" "HTTP/REST"
        apiGateway -> analyticsService "Маршрутизирует запросы" "HTTP/REST"

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

        # Связи компонентов внутри сервисов
        apiGateway -> authController "Аутентификация и авторизация" "HTTP/REST"
        apiGateway -> userController "Управление пользователями" "HTTP/REST"
        brigadeService -> userController "Управление пользователями" "HTTP/REST"
        authController -> authBusinessLogic
        userController -> userBusinessLogic
        authBusinessLogic -> userRepository
        userBusinessLogic -> userRepository
        userRepository -> usersDB "Чтение/запись" "SQL"

        apiGateway -> brigadeRouter "Управление бригадами" "HTTP/REST"
        inspectionService -> brigadeRouter "Управление бригадами" "HTTP/REST"
        analyticsService -> brigadeRouter "Управление бригадами" "HTTP/REST"
        brigadeRouter -> brigadeBusinessLogic
        brigadeBusinessLogic -> userService "Получает информацию об инспекторах" "HTTP/REST"
        brigadeBusinessLogic -> messageBroker "Подписан на события задач" "Kafka"
        brigadeBusinessLogic -> brigadeRepository
        brigadeRepository -> brigadesDB "Чтение/запись" "SQL"

        apiGateway -> contractRouter "Управление договорами" "HTTP/REST"
        apiGateway -> objectRouter "Управление объектами проверки" "HTTP/REST"
        apiGateway -> registryRouter "Управление реестром" "HTTP/REST"
        apiGateway -> subscriberRouter "Управление абонентами" "HTTP/REST"
        inspectionService -> contractRouter "Управление договорами" "HTTP/REST"
        analyticsService -> objectRouter "Управление объектами проверки" "HTTP/REST"
        contractRouter -> contractBusinessLogic
        objectRouter -> objectBusinessLogic
        registryRouter -> registryBusinessLogic
        subscriberRouter -> subscriberBusinessLogic
        contractBusinessLogic -> taskService "Получает информацию о задачах" "HTTP/REST"
        contractBusinessLogic -> messageBroker "Подписан на события проверок" "Kafka"
        contractBusinessLogic -> contractRepository
        contractBusinessLogic -> subscriberRepository
        objectBusinessLogic -> objectRepository
        registryBusinessLogic -> contractRepository
        registryBusinessLogic -> objectRepository
        registryBusinessLogic -> subscriberRepository
        subscriberBusinessLogic -> subscriberRepository
        contractRepository -> objectRepository
        contractRepository -> subscriberRepository
        contractRepository -> subscribersDB "Чтение/запись" "SQL"
        objectRepository -> subscribersDB "Чтение/запись" "SQL"
        subscriberRepository -> subscribersDB "Чтение/запись" "SQL"

        apiGateway -> taskRouter "Управление задачами" "HTTP/REST"
        inspectionService -> taskRouter "Управление задачами" "HTTP/REST"
        subscriberService -> taskRouter "Управление задачами" "HTTP/REST"
        taskRouter -> taskBusinessLogic
        taskBusinessLogic -> messageBroker "Публикует события задач и подписан на события проверок" "Kafka"
        taskBusinessLogic -> taskRepository
        taskRepository -> tasksDB "Чтение/запись" "SQL"

        apiGateway -> inspectionRouter "Управление проверками" "HTTP/REST"
        analyticsService -> inspectionRouter "Управление проверками" "HTTP/REST"
        inspectionRouter -> inspectionBusinessLogic
        inspectionBusinessLogic -> analyzerService "Проверяет фото приборов учета" "HTTP/REST"
        inspectionBusinessLogic -> fileService "Сохраняет фотографии и акты" "HTTP/REST"
        inspectionBusinessLogic -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        inspectionBusinessLogic -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        inspectionBusinessLogic -> taskService "Получает информацию о задачах" "HTTP/REST"
        inspectionBusinessLogic -> messageBroker "Публикует события проверок и подписан на события задач" "Kafka"
        inspectionBusinessLogic -> inspectionRepository
        inspectionRepository -> inspectionsDB "Чтение/запись" "SQL"

        apiGateway -> fileRouter "Управление файлами" "HTTP/REST"
        inspectionService -> fileRouter "Сохраняет фотографии и акты" "HTTP/REST"
        analyticsService -> fileRouter "Сохраняет отчеты" "HTTP/REST"
        fileRouter -> fileBusinessLogic
        fileBusinessLogic -> fileRepository
        fileBusinessLogic -> fileStorage
        fileRepository -> filesDB "Чтение/запись" "SQL"
        fileStorage -> objectStorage "Чтение/запись" "HTTP"

        apiGateway -> analyticsRouter "Управление аналитикой" "HTTP/REST"
        analyticsRouter -> analyticsBusinessLogic
        cronService -> analyticsBusinessLogic
        analyticsBusinessLogic -> fileService "Сохраняет отчеты" "HTTP/REST"
        analyticsBusinessLogic -> subscriberService "Получает информацию об абонентах" "HTTP/REST"
        analyticsBusinessLogic -> brigadeService "Получает информацию о бригадах" "HTTP/REST"
        analyticsBusinessLogic -> inspectionService "Получает информацию о проверках" "HTTP/REST"
        analyticsBusinessLogic -> messageBroker "Подписан на события задач" "Kafka"
        analyticsBusinessLogic -> analyticsRepository
        analyticsRepository -> reportsDB "Чтение/запись" "SQL"
        analyticsRepository -> analyticsDB "Чтение/запись" "SQL"

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

        # Диаграмма компонентов User Service
        component userService "UserServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов User Service"
            description "Показывает внутреннюю архитектуру сервиса управления пользователями"
        }

        # Диаграмма компонентов Brigade Service
        component brigadeService "BrigadeServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов Brigade Service"
            description "Показывает внутреннюю архитектуру сервиса управления бригадами"
        }

        # Диаграмма компонентов Subscriber Service
        component subscriberService "SubscriberServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов Subscriber Service"
            description "Показывает внутреннюю архитектуру сервиса управления абонентами"
        }

        # Диаграмма компонентов Task Service
        component taskService "TaskServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов Task Service"
            description "Показывает внутреннюю архитектуру сервиса управления задачами"
        }

        # Диаграмма компонентов Inspection Service
        component inspectionService "InspectionServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов Inspection Service"
            description "Показывает внутреннюю архитектуру сервиса управления проверками"
        }

        # Диаграмма компонентов File Service
        component fileService "FileServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов File Service"
            description "Показывает внутреннюю архитектуру сервиса управления файлами"
        }

        # Диаграмма компонентов Analytics Service
        component analyticsService "AnalyticsServiceComponents" {
            include *
            autoLayout
            title "Диаграмма компонентов Analytics Service"
            description "Показывает внутреннюю архитектуру сервиса управления отчетами и аналитики"
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
