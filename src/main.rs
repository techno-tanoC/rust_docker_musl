fn main() {
    let body = reqwest::get("https://example.net/").unwrap().text().unwrap();
    println!("{}", &body);
}
