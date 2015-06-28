class Bullseye
  attr_reader :person

  def initialize(person)
    @person = person
  end

  def call
    second_degree_only || random_not_connected || can_connect_more
  end

  private

  def second_degree_only
    Person.
        where(uuid: person.uuid).
        query_as(:person).
        match("person-[r:knows*2]-match").
        where("NOT person-[:knows]-match").
        where("person <> match").
        return(:match).
        first.try!(:match)
  end

  def random_not_connected
    Person.
        where("result_person.uuid <> {uuid}").
        where("NOT result_person-[:knows]-()").
        params(uuid: person.uuid).
        first
  end

  def can_connect_more
    Person.
        where(uuid: person.uuid).
        query_as(:person).
        match("person-[r:knows]-match").
        where("person <> match").
        where("r.weight < {max_weight}").
        return(:match).
        params(max_weight: PersonConnection::MAX_WEIGHT).
        first.try!(:match)
  end
end