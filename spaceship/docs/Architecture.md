# Spaceship Architecture

## Overview

Spaceship wraps various APIs using the following pattern:

A simple `client` and various data models, usually subclassed from a `Base` model (e.g. Spaceship::TestFlight::Base)
The `client` is responsible for making HTTP requests for a given API or domain. It should be very simple and have no logic.
It is only responsible for creating the request and parsing the response. The best practice is for each method to have a single request and return the data from the response.

The data models generally map to a REST resource or some logical grouping of data. Each data model has an instance of `client` which it can use to put or get data. It should encapsulate all interactions with the API, so other _fastlane_ tools interface with the data models, and not the `client` directly.
