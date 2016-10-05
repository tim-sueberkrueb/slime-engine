/*
 * This file is part of Slime Engine
 * Copyright (C) 2016 Tim Süberkrüb (https://github.com/tim-sueberkrueb)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

.pragma library

var BadIdentity = 1
var Expired = 2
var DateInvalid = 3
var AuthorityInvalid = 4
var Revoked = 5
var Invalid = 6
var Insecure = 7
var Generic = 7

var names = [
    "BadIdentity",
    "Expired",
    "DateInvalid",
    "AuthorityInvalid",
    "Revoked",
    "Invalid",
    "Insecure",
    "Generic"
]
