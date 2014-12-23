# Copyright 2014 Boundary, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

__data = dict()


def accumulate(key, new_value):
    global __data

    try:
        old_value = __data[key]
    except KeyError:
        old_value = new_value

    diff = new_value - old_value
    __data[key] = new_value
    return diff


def reset(key):
    global __data

    try:
        del __data[key]
    except KeyError:
        pass


def reset_all():
    global __data
    __data = {}
