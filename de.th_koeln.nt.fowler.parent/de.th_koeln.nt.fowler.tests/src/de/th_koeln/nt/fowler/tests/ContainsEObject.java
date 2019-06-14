package de.th_koeln.nt.fowler.tests;

import java.util.Iterator;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.stream.Stream;
import java.util.stream.StreamSupport;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.hamcrest.BaseMatcher;
import org.hamcrest.Description;
import org.hamcrest.Factory;

public class ContainsEObject extends BaseMatcher<Iterator<? extends EObject>> {

	private EObject actual;

	public ContainsEObject(EObject actual) {
		this.actual = actual;
	}

	@Override
	public void describeTo(Description description) {
		description.appendText(actual.toString());
	}

	@Override
	public boolean matches(Object object) {
		if (object instanceof Iterator<?>) {
			try {
				@SuppressWarnings("unchecked")
				Iterator<EObject> list = (Iterator<EObject>) object;
				Stream<EObject> objectStream = StreamSupport
						.stream(Spliterators.spliteratorUnknownSize(list, Spliterator.NONNULL), false);
				if (objectStream.anyMatch(item -> EcoreUtil.equals(item, actual))) {
					return true;
				} else {
					return false;
				}
			} catch (ClassCastException e) {
				return false;
			}

		}

		return false;
	}

	@Factory
	public static ContainsEObject containsEObject(EObject actual) {
		return new ContainsEObject(actual);
	}

}

