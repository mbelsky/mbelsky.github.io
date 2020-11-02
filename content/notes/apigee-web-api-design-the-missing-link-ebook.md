---
title: "Summary: Web Api Design the Missing Link"
date: 2020-10-19T19:06:13+03:00
description: "My summary for Web Api Design the Missing Link"
draft: false
tags: ["summary", "api"]
---

The ebook: [.PDF](https://cloud.google.com/files/apigee/apigee-web-api-design-the-missing-link-ebook.pdf)

## Relationship between models

Assume that there is a relationship between a dog and
its owner. A popular way to represent it:

```json
{
  "id": "12345678",
  "name": "Lassie",
  "ownerID": "98765432" // the relationship
}
```

A better way:

```json
{
  "id": "12345678",
  "name": "Lassie",
  "ownerID": "98765432",
  "ownerLink": "https://dogtracker.com/persons/1337" // Use links
}
```

The owner representation:

```json
{
  "id": "98765432",
  "kind": "Person",
  "name": "Joe Carraclough",
  "dogsLink": "https://dogtracker.com/persons/98765432/dogs" // 🐶
}
```

Suppose dogs can be owned by either people or institutions (e.g. companies). At this point, it is no longer enough to have an `ownerID` property to reference the owner—you also need to specify what type of owner it is.

Multiple solutions are possible:

- You could have `ownerID` and `ownerType` properties
- you could have separate `personOwnerID` and `institutionalOwnerID` properties only one of which may be set at a time
- you could invent a compound `owner` value that encoded both the type and the ID

But a very elegant and flexible option is to use links to solve the problem:

```json
{
  "self": "https://dogtracker.com/dogs/12345678",
  "id": "12345678",
  "kind": "Dog",
  "name": "Lassie",
  "owner": "https://dogtracker.com/persons/98765432"
}
```

> The server should strip the scheme and authority from URLs that identify its own resources before storing them, and put them back when they are requested. Any URLs that identify resources that are completely external to your API will probably have to be stored as absolute URLs. If you are not very experienced with absolute URLs in databases, don’t do it.

### Collections

```json
{
  "self": "https://dogtracker.com/dogs",
  "kind": "Collection",
  "contents": [
    {
      "self": "https://dogtracker.com/dogs/12344",
      "kind": "Dog",
      "name": "Fido"
    },
    {
      "self": "https://dogtracker.com/dogs/12345",
      "kind": "Dog",
      "name": "Rover"
    }
  ]
}
```

The `contents` field as an array of URLs would be another good option if your clients don't need any data about each of the content resources.

[Collection+JSON](http://amundsen.com/media-types/collection/format/)

### Paginated collections

```sh
>>>

GET /dogs HTTP/1.1
Host: dogtracker.com
Accept: application/json

<<<

HTTP/1.1 303 See Other
Location: https://dogtracker.com/dogs?limit=25,offset=0
```

Response:

```sh
{
  "self": "https://dogtracker.com/dogs?limit=25,offset=0",
  "kind": "Page",
  "pageOf": "https://dogtracker.com/dogs",
  "next": "https://dogtracker.com/dogs?limit=25,offset=25",
  // previous: URL
  // first: URL
  // last: URL
  "contents": [
    {
      "self": "https://dogtracker.com/dogs/12344",
      "kind": "Dog",
      "name": "Fido",
    },
    {
      "self": "https://dogtracker.com/dogs/12345",
      "kind": "Dog",
      "name": "Rover",
    }
    // … (23 more)
  ]
}
```

## Designing URLs

In URLs, nouns are good; verbs are bad.

### Path parameters, or matrix parameters

```sh
// Pattern

_/{relationship-name}[;{selector}]/…/{relationship-name}[;{selector}]_

// Examples

/persons;5678/dogs
/persons;id=5678/dogs # synonym for the previous URL
/persons;name=JoeMCarraclough/dogs
```

### Responses that don’t involve persistent resources

API calls that return a response that is not the representation of a persistent resource are common. In these cases, it is not necessary to depart from our noun-based, document-based model. The key insight is that the URL should identify the resource in the response, not the processing algorithm that calculates the response.

Examples:

```sh
/monetary-amount?quantity=100&unit=EUR&in=CNY
/monetary-amount/100/EUR/CNY
```

#### GET content negotiation

Req:

```sh
GET /monetary-amount/100/EUR HTTP/1.1
Host: currency-converter.com
Accept-Currency:CNY
```

Res:

```sh
683.92CNY
```

#### POST noun-based

Req:

```sh
POST /currency-converter HTTP/1.1

{
"amount": 100,
"inputCurrency": "EUR",
"outputCurrency": "CNY"
}
```

Res:

```sh
683.92
```

### Partial response

```
/joe.smith/friends?fields=id,name,picture
```

## Handling Errors ??

## Modeling Actions ??

## Auth: OAuth2 always
