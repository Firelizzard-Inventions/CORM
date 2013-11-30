prebuild:
	git submodule init; \
	git submodule update; \
	for PROJ in Include/*; do \
		cd $$PROJ; \
		git checkout master; \
		git pull; \
		make prebuild; \
		cd ../..; \
	done
