import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class Db2iDataSimulator {

    // Connection configuration
    private static final String HOST = "10.3.61.2";
    private static final String DATABASE = "K70F3B70";       // often optional for IBM i
    private static final String USER = "benoit";
    private static final String PASSWORD = "xxxxx";
    private static final String LIBRARY = "APP";       // your schema/library
    private static final int MIN_ORDER_ID = 1;
    private static final int MAX_ORDER_ID = 100;
    private static final int MIN_ITEM_ID = 1;
    private static final int MAX_ITEM_ID = 500;

    private static final String[] STATUSES = {"PENDING", "SHIPPED", "DELIVERED", "CANCELLED"};
    private static final Random RANDOM = new Random();

    public static void main(String[] args) {
        String url = String.format(
            "jdbc:as400://%s/%s;user=%s;password=%s;naming=system;libraries=%s;prompt=false;",
            HOST, DATABASE, USER, PASSWORD, LIBRARY
        );

        try (Connection conn = DriverManager.getConnection(url)) {
            System.out.println("✅ Connected to DB2 for i at " + HOST);

            while (true) {
                updateRandomOrder(conn);
                updateRandomOrderItem(conn);

                // Sleep between 1 and 5 seconds
                int delay = 1 + RANDOM.nextInt(5);
                TimeUnit.SECONDS.sleep(delay);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void updateRandomOrder(Connection conn) throws SQLException {
        int orderId = randomInt(MIN_ORDER_ID, MAX_ORDER_ID);
        String newStatus = STATUSES[RANDOM.nextInt(STATUSES.length)];

        String sql = String.format("UPDATE %s.ORDERS SET STATUS = ? WHERE ORDER_ID = ?", LIBRARY);
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            int rows = ps.executeUpdate();
            if (rows > 0)
                System.out.printf("🔄 Updated order %d → status=%s%n", orderId, newStatus);
        }
    }

    private static void updateRandomOrderItem(Connection conn) throws SQLException {
        int itemId = randomInt(MIN_ITEM_ID, MAX_ITEM_ID);
        int newQty = randomInt(1, 10);

        String sql = String.format("UPDATE %s.ORDER_ITEMS SET QTY = ? WHERE ITEM_ID = ?", LIBRARY);
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQty);
            ps.setInt(2, itemId);
            int rows = ps.executeUpdate();
            if (rows > 0)
                System.out.printf("🧮 Updated item %d → QTY=%d%n", itemId, newQty);
        }
    }

    private static int randomInt(int min, int max) {
        return RANDOM.nextInt(max - min + 1) + min;
    }
}
