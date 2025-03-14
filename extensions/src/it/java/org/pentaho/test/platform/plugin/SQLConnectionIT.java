/*! ******************************************************************************
 *
 * Pentaho
 *
 * Copyright (C) 2024 by Hitachi Vantara, LLC : http://www.pentaho.com
 *
 * Use of this software is governed by the Business Source License included
 * in the LICENSE.TXT file.
 *
 * Change Date: 2029-07-20
 ******************************************************************************/


package org.pentaho.test.platform.plugin;

import org.pentaho.test.platform.engine.core.BaseTestCase;
import org.pentaho.test.platform.utils.TestResourceLocation;

import java.io.File;

@SuppressWarnings( "nls" )
public class SQLConnectionIT extends BaseTestCase {
  private static final String SOLUTION_PATH = TestResourceLocation.TEST_RESOURCES + "/solution";
  private static final String ALT_SOLUTION_PATH = TestResourceLocation.TEST_RESOURCES + "/solution";
  private static final String PENTAHO_XML_PATH = "/system/pentaho.xml";

  public String getSolutionPath() {
    File file = new File( SOLUTION_PATH + PENTAHO_XML_PATH );
    if ( file.exists() ) {
      System.out.println( "File exist returning " + SOLUTION_PATH );
      return SOLUTION_PATH;
    } else {
      System.out.println( "File does not exist returning " + ALT_SOLUTION_PATH );
      return ALT_SOLUTION_PATH;
    }

  }

  /*
   * public void testSQLConnection() { SimpleParameterProvider parameters = new SimpleParameterProvider(); OutputStream
   * outputStream = getOutputStream(SOLUTION_PATH, "Chart_Bubble", ".html"); //$NON-NLS-1$ //$NON-NLS-2$
   * SimpleOutputHandler outputHandler = new SimpleOutputHandler(outputStream, true); IRuntimeContext context =
   * run(getSolutionPath() + "/test/datasource/", "SQL_Datasource.xaction", parameters, outputHandler); //$NON-NLS-1$
   * assertEquals( Messages.getString("BaseTest.USER_RUNNING_ACTION_SEQUENCE"), IRuntimeContext.RUNTIME_STATUS_SUCCESS,
   * context.getStatus()); //$NON-NLS-1$ }
   */
  public void testDummyTest() {
    // have to have at least one test method to make JUnit happy
  }

}
