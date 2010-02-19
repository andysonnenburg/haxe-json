package com.rational.utils;

interface IProperty {
	function getAccess():String;
	function getType():Class<Dynamic>;
	function getElementType():Class<Dynamic>;
}
