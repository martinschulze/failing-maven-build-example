package de.th_koeln.nt.fowler.tests;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.hamcrest.Description;
import org.hamcrest.Factory;
import org.hamcrest.TypeSafeMatcher;

public class EqualsEObject extends TypeSafeMatcher<EObject> {

	private EObject actual;

	public EqualsEObject(EObject actual) {
		this.actual = actual;
	}

	@Override
	public void describeTo(Description description) {
		description.appendText(actual.toString());
	}

	@Override
	protected boolean matchesSafely(EObject item) {
		if (EcoreUtil.equals(item, actual)) {
			return true;
		} else {
			return false;
		}
	}

	@Factory
	public static EqualsEObject equalsEObject(EObject actual) {
		return new EqualsEObject(actual);
	}
}
