#!/bin/bash
    if [ "$1" = "Up" ]; then
                Is_App_Up="Primary_App_Is_Up"
    else
                Is_App_Up="Primary_App_Is_Down"
    fi
echo $Is_App_Up
echo `date` >> /tmp/log
