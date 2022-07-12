# GrpcVcr

This package helps repeat Ruby vcr gem behaviour in GRPC, and record requests with responses to json
files.

## Getting started

Add package to dev_dependencies of the project by running

```
    dart pub add --dev grpc_vcr    
```

or

```
    flutter pub add --dev grpc_vcr    
```

if you are using it in Flutter project

## Usage

Create a interceptor instance in your tests

```dart

final vcrInterceptor = GrpcVcpInterceptor();
```

and use it to create GRPC service client

```dart

final channel = ClientChannel('127.0.0.1',
    port: 8080,
    options: const ChannelOptions(),
);
final client = ExampleClient(channel, interceptors: [vcrInterceptor]);
```

Every request 
