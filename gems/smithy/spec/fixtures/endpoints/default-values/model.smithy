$version: "2.0"

namespace smithy.tests.endpointrules.defaultvalues

use smithy.rules#clientContextParams
use smithy.rules#endpointRuleSet
use smithy.rules#endpointTests

@suppress(["UnstableTrait"])
@clientContextParams(
    bar: {type: "string", documentation: "a client string parameter"}
    baz: {type: "string", documentation: "another client string parameter"}
)
@endpointRuleSet({
    version: "1.0",
    parameters: {
        bar: {
            type: "string",
            documentation: "docs"
        }
        baz: {
            type: "string",
            documentation: "docs"
            required: true
            default: "baz"
        },
        endpoint: {
            type: "string",
            builtIn: "SDK::Endpoint",
            required: true,
            default: "asdf"
            documentation: "docs"
        },
    },
    rules: [
        {
            "conditions": [
                {
                    "fn": "isSet",
                    "argv": [
                        {
                            "ref": "bar"
                        }
                    ]
                }
            ],
            "endpoint": {
                "url": "https://example.com/{baz}"
            },
            "type": "endpoint"
        },
        {
            "conditions": [],
            "documentation": "error fallthrough",
            "error": "endpoint error",
            "type": "error"
        }
    ]
})
@endpointTests({
    "version": "1.0",
    "testCases": [
        {
            "documentation": "Default value is used when parameter is unset",
            "params": {
                "bar": "a b",
            }
            "operationInputs": [{
                                    "operationName": "GetThing",
                                    "builtInParams": {
                                        "SDK::Endpoint": "https://custom.example.com"
                                    },
                                    "clientParams": {
                                        "bar": "a b"
                                    }
                                }],
            "expect": {
                "endpoint": {
                    "url": "https://example.com/baz"
                }
            }
        },
        {
            "documentation": "Default value is not used when the parameter is set",
            "params": {
                "bar": "a b",
                "baz": "BIG"
            }
            "operationInputs": [{
                                    "operationName": "GetThing",
                                    "builtInParams": {
                                        "SDK::Endpoint": "https://custom.example.com"
                                    },
                                    "clientParams": {
                                        "bar": "a b",
                                        "baz": "BIG"
                                    }
                                }],
            "expect": {
                "endpoint": {
                    "url": "https://example.com/BIG"
                }
            }
        },
        {
            "documentation": "a documentation string",
            "expect": {
                "error": "endpoint error"
            }
        }
    ]
})
service FizzBuzz {
    version: "2022-01-01",
    operations: [GetThing]
}

operation GetThing {
    input := {}
}
