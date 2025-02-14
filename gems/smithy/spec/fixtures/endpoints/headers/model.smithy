$version: "2.0"

namespace smithy.tests.endpointrules.headers

use smithy.rules#clientContextParams
use smithy.rules#endpointRuleSet
use smithy.rules#endpointTests

@suppress(["UnstableTrait"])
@endpointRuleSet({
    "version": "1.0",
    "parameters": {
        "Region": {
            "type": "string",
            "documentation": "The region to dispatch this request, eg. `us-east-1`."
        }
    },
    "rules": [
        {
            "documentation": "Template the region into the URI when region is set",
            "conditions": [
                {
                    "fn": "isSet",
                    "argv": [
                        {
                            "ref": "Region"
                        }
                    ]
                }
            ],
            "endpoint": {
                "url": "https://{Region}.amazonaws.com",
                "headers": {
                    "x-amz-region": [
                        "{Region}"
                    ],
                    "x-amz-multi": [
                        "*",
                        "{Region}"
                    ]
                }
            },
            "type": "endpoint"
        },
        {
            "documentation": "fallback when region is unset",
            "conditions": [],
            "error": "Region must be set to resolve a valid endpoint",
            "type": "error"
        }
    ]
})
@endpointTests(
    "version": "1.0",
    "testCases": [
        {
            "documentation": "header set to region",
            "params": {
                "Region": "us-east-1"
            },
            "expect": {
                "endpoint": {
                    "url": "https://us-east-1.amazonaws.com",
                    "headers": {
                        "x-amz-region": [
                            "us-east-1"
                        ],
                        "x-amz-multi": [
                            "*",
                            "us-east-1"
                        ]
                    }
                }
            }
        }
    ]
)
@clientContextParams(
    Region: {type: "string", documentation: "docs"}
)
service FizzBuzz {}
