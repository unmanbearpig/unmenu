use std::io::BufRead;

mod lib;

fn main() {
    let mut matcher = lib::Matcher::new().expect("couldn't create matcher");
    matcher.rescan();
    for item in matcher.items.iter() {
        println!("item = {item:?}");
    }

    let stdin = std::io::stdin();
    let input_lines = stdin.lock().lines().map(Result::unwrap);

    for line in input_lines {
        println!("Received input: {}", line);
        let results = matcher.search(&line);
        println!("results = {results:?}");

        if line == "exit" {
            break;
        }
    }
}
