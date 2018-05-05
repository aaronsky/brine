Feature: Smoke Test the App Outlines

Scenario Outline: jamming
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

    Examples:
        | start | eat | left |
        |  12   |  5  |  7   |
        |  20   |  5  |  15  |
