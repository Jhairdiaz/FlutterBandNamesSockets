class Band {

  String id = '1';
  String name = 'name';
  int votes = 0;

  Band({
    id,
    name,
    votes
  });

  factory Band.fromMap( Map<String, dynamic> obj )
  => Band(
    id: obj['id'],
    name: obj['name'],
    votes: obj['votes']
  );


}