typedef ::name:: = Int;
class ::name::s {
::foreach constant constants::
	public static inline var ::constant:::::name:: = $$next;
::end::
}
