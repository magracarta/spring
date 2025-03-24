<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > 부품CUBE등록 > null
-- 작성자 : 박예진
-- 최초 작성일 : 2021-04-09 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		$(document).ready(function() {
			createAUIGrid();
			goSearch(); // 초기검색
		});

		// 멀티 그리드
		var auiGrids = [];
		var selectBukkit = 0;
		var bukkitSizeList = [
				'대버켓', '중버켓', '소버켓', '퀵클램프'
				// 'B','M','S','Q'
		]
		var bukkitSizeListName = [
			{
				name : '대버켓',
				code : 'B'
			},
			{
				name :'중버켓',
				code : 'M'
			},
			{
				name : '소버켓',
				code : 'S'
			}, {
				name : '퀵클램프',
				code : 'Q'
			}
		]

		//그리드생성
		function createAUIGrid() {
			var gridPros = [
				{
					rowIdField : "_$uid",
					showRowNumColum: true,
					showStateColumn: true,
					editable : true,
				}, {
					rowIdField : "_$uid",
					showRowNumColum: true,
					showStateColumn: true,
					editable : true,
				}, {
					rowIdField : "_$uid",
					showRowNumColum: true,
					showStateColumn: true,
					editable : true,
				}
			];
			var columnLayouts = [
				[ //////////////////////////////////////////////////////////////////////// 제 0 그리드
					{
						headerText: "버켓번호",
						// dataField: "machine_bucket_seq",
						dataField: "bucket_seq",
						visible : false,
					},{
						headerText: "모델명",
						dataField: "bucket_name",
						width: "120",
						minWidth: "120",
						style: "aui-editable",
						// visible : false,
						editable: true
					},{
						headerText: "비고",
						dataField: "remark",
						// width: "160",
						minWidth: "150",
						style: "aui-editable",
						// visible : false,
						editable: true
					},
					{
						headerText: "사용여부",
						dataField: "use_yn",
						width: "100",
						minWidth: "100",
						style: "aui-center",
						editable: true,
						filter : { showIcon : true },
						renderer: {
							type : "CheckBoxEditRenderer",
							checked : true,
							checkValue : "Y",
							unCheckValue : "N",
							editable : true
						},
					},{
						headerText: "모델개수",
						dataField: "bukkit_count",
						width: "160",
						minWidth: "150",
						style: "aui-center aui-popup",
						// visible : false,
						editable: false
					},{
						headerText: "순서",
						dataField: "sort_no",
						width: "70",
						minWidth: "70",
						style: "aui-editable",
						// visible : false,
						editable: true
					},
				], [ //////////////////////////////////////////////////////////////////////// 제 1 그리드
					{
						headerText: "장비번호",
						dataField: "machine_plant_seq",
						visible : false,
					},{
						headerText: "메이커",
						dataField: "maker_name",
						width: "160",
						minWidth: "150",
						style: "aui-center",
						// visible : false,
						editable: false
					},{
						headerText: "모델명",
						dataField: "machine_name",
						width: "160",
						minWidth: "150",
						style: "aui-center",
						// visible : false,
						editable: false
					},
					// {
					// 	headerText: "구성품번",
					// 	dataField: "group_code",
					// 	width: "160",
					// 	minWidth: "150",
					// 	style: "aui-center",
					// 	// visible : false,
					// 	editable: true
					// },
					{
						headerText: "구성품개수",
						dataField: "machine_count",
						width: "180",
						minWidth: "180",
						style: "aui-center aui-popup",
						// visible : false,
						editable: false
					},{
						headerText : "삭제",
						dataField : "removeBtn",
						width : "55",
						minWidth : "55",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								if (event.item.part_no) {
									var in_ = confirm("모델을 삭제할 경우 품번이 삭제됩니다.\n삭제 하시겠습니까?");
									if ( in_ ){
										var param = {
											// "maker_cd" : $M.getValue("s_maker_cd")
											bukkit_id : bukkit_idx,
											machne : event.item.machine_plant_seq,
										};

										goAjax(false, this_page + "/delete", $M.toGetParam(param), {method : 'GET'},
												function(result) {
													if(result.success) {
														getItem(0, bukkit_idx);
													}
												}
										);
									}
								}else{
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(auiGrids[2]);
								}

							},
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return '삭제'
						},
						style : "aui-center",
						editable : false,
					},
				], [ //////////////////////////////////////////////////////////////////////// 제 2 그리드
					{
						headerText: "버킷번호",
						dataField: "machine_bucket_seq",
						visible : false,
					},{
						headerText: "장비번호",
						dataField: "machine_plant_seq",
						visible : false,
					},
					{ // 부품번호
						headerText: "품번",
						dataField: "part_no",
						width: "160",
						minWidth: "150",
						style: "aui-center",
						// visible : false,
						editable: false
					},{
						headerText: "버킷사이즈",
						dataField: "bucket_size_bms",
						// width: "160",
						minWidth: "150",
						style : "aui-center aui-editable",
						// visible : false,
						editable: true,
						editRenderer : {
							type : "DropDownListRenderer",
							list : bukkitSizeListName,
							showEditorBtn : true,
							showEditorBtnOver : true,
							keyField : "code",
							valueField  : "name",
							editable : true,
						},
						labelFunction : function(rowIndex, columnIndex, value){
							for(var i=0; i<bukkitSizeListName.length; i++){
								if(value == bukkitSizeListName[i].code){
									return bukkitSizeListName[i].name;
								}
							}
							return value;
						}
					},
					{
						headerText: "기본제공여부",
						dataField: "base_yn",
						width: "100",
						minWidth: "100",
						style: "aui-center",
						editable: false,
						filter : { showIcon : true },
						renderer: {
							type : "CheckBoxEditRenderer",
							checked : true,
							checkValue : "Y",
							unCheckValue : "N",
							editable : true
						},
					},{
						headerText : "삭제",
						dataField : "removeBtn",
						width : "55",
						minWidth : "55",
						renderer : {
							type : "ButtonRenderer",
							onClick : function(event) {
								var isRemoved = AUIGrid.isRemovedById(auiGrids[2], event.item._$uid);
								console.log(isRemoved)
								if (isRemoved == false) {
									AUIGrid.removeRow(event.pid, event.rowIndex);
									AUIGrid.update(auiGrids[2]);
								} else {
									AUIGrid.restoreSoftRows(auiGrids[2], "selectedIndex");
									AUIGrid.update(auiGrids[2]);
								};
							},
						},
						labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
							return '삭제'
						},
						style : "aui-center",
						editable : false,
					},
				],
			];

			// 그리드들
			for (var i = 0; i < 3; i ++ ){
				var auiGrid = AUIGrid.create("#auiGrid" + i, columnLayouts[i], gridPros[i]);
				AUIGrid.setGridData(auiGrid, []); // 데이터 설정
				AUIGrid.bind(auiGrid, "cellClick", clickItem); // 셀클릭 이벤트

				auiGrids[i] = auiGrid;

				$("#auiGrid" + i).resize();
			}
			// 에디팅 정상 종료 이벤트 바인딩
			// AUIGrid.bind(auiGridRight, "cellEditEndBefore", auiCellEditHandlerRight);
			// // 에디팅 정상 종료 이벤트 바인딩
			// AUIGrid.bind(auiGridRight, "cellEditEnd", auiCellEditHandlerRight);
			// // 에디팅 취소 이벤트 바인딩
			// AUIGrid.bind(auiGridRight, "cellEditCancel", auiCellEditHandlerRight);
		}

		var bucketMachne = {}; // 호환모델의 품번 리스트
		var bukkit_idx = -1;
		var match_idx = -1;

		function clickItem(event){
			switch(event.dataField){
				case "bukkit_count" : // 버킷개수 선택
					var idx=  checkedEditableColumns(0);
					console.log(idx)
					if ( idx != -1 && idx != 1){ // 저장경고
						var in_ = confirm(idx = 0 ? "저장되지 않은 버킷이 있습니다.\n저장 하시겠습니까?" : "저장되지 않은 품번이 있습니다.\n저장 하시겠습니까?");
						if (in_) // 정보저장
							if ( idx == 0) {
								goSave(function(result){
									getItem(0, event.item.machine_bucket_seq);
								});
							}else {
								goSaveModel(function(result){
									getItem(1, event.item.machine_plant_seq);
								});
							}
						else {
							if ( event.item.machine_bucket_seq != 0) {
								getItem(0, event.item.machine_bucket_seq);
							}else{
								alert("버킷을 저장하지 않으면 호환모델 설정을 할수 없습니다.");
								// goSearch();
							}
						}
						return;
					}
					getItem(0, event.item.machine_bucket_seq);
					break;
				case "machine_count" : // 호환모델클릭(구성품 개수)
					if ( checkedEditableColumns(2) != -1) { // 저장경고
						var in_ = confirm("저장되지 않은 품번이 있습니다.\n저장 하시겠습니까?");
						if (in_) // 정보저장
							goSaveModel(function(result){
								getItem(1, event.item.machine_plant_seq);
							});
						else {
							getItem(1, event.item.machine_plant_seq);
						}
						return;
					}
					getItem(1, event.item.machine_plant_seq);
					break;
			}
		}

		/**
		 *
		 * @param idx
		 */
		function getItem(grid_idx, idx){
			var param = {
				"maker_cd" : $M.getValue("s_maker_cd"),
			};

			console.log("아이템 선택", grid_idx, idx)



			switch(grid_idx){
				case 0:
					bukkit_idx = idx; // 시퀀스 저장 - 버킷번호

					// AUIGrid.setGridData(auiGrids[2], []); // 품번제거
					$M.goNextPageAjax(this_page + "/" + bukkit_idx, $M.toGetParam(param), {method : 'GET'},
						function(result) {
							if(result.success) {
								console.log(result.list)
								var list = []
								for (var model_key in result.list){ // 모델만 추출
									var model = result.list[model_key][0];
									model.machine_count = model.part_no + "등 " + result.list[model_key].length + "건"; // 하위모델 개수
									list.push(model);
									console.log(model ,"모델");
								}
								bucketMachne = result.list
								match_idx = -1; // 장비 선택 초기화
								AUIGrid.setGridData(auiGrids[1], list);
								AUIGrid.setGridData(auiGrids[2], []);
							}
						}
					);
					break;
				case 1:
					match_idx = idx;
					if ( bucketMachne[match_idx] )
						AUIGrid.setGridData(auiGrids[2], bucketMachne[match_idx]);
					else AUIGrid.setGridData(auiGrids[2], []);
					break;
				case 2: break;
			}
		}

		// 조회 -
		function goSearch(){
			var param = {
				"maker_cd" : $M.getValue("s_maker_cd"),
				"use_yn" : $M.getValue("s_use_yn"),
				"bucket_name" : $M.getValue("s_model")
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'GET'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrids[0], result.list);
						}
					}
			);
		}

		/**
		 * 저장 - 버킷 저장
		 * @param callbacks 반환이 필요한 경우(저장후 별도처리 필요시)
		 */
		function goSave(callbacks) {
			if (fnChangeGridDataCnt(auiGrids[0]) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			if( !fnCheckGridEmpty(0) ){
				return;
			}

			var columns = ["machine_bucket_seq", "bucket_name", "remark", "use_yn", "sort_no"];

			var gridFrm = fnChangeGridDataToForm(auiGrids[0], true, columns);
			console.log(gridFrm);

			goAjax(!callbacks, this_page + "/save", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							goSearch();
							if ( callbacks )
								callbacks();
							opener.location.reload();
						}
					}
			);
		}

		// 메세지 여부
		function goAjax(is, nextUrl, paramObj, options, execFunc){
			if ( is )
				$M.goNextPageAjaxMsg('저장하시겠습니까?', nextUrl, paramObj, options, execFunc);
			else {
				$M.goNextPageAjax(nextUrl, paramObj, options, execFunc);
			}
		}

		function goChangeSave(){
			goSaveModel();
		}

		/**
		 * 저장 - 호환모델 저장
		 * @param callbacks 반환이 필요한 경우(저장후 별도처리 필요시)
		 */
		function goSaveModel(callbacks) {
			if (fnChangeGridDataCnt(auiGrids[2]) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			}

			if( !fnCheckGridEmpty(2) ){
				return;
			}

			var columns = ["machine_bucket_seq", "machine_plant_seq", "part_no", "bucket_size_bms", "base_yn"];

			var gridFrm = fnChangeGridDataToForm(auiGrids[2], undefined, columns);
			console.log(gridFrm);

			goAjax(!callbacks, this_page + "/save/machne", gridFrm, {method: "POST"},
					function (result) {
						if (result.success) {
							getItem(0, bukkit_idx);
							if ( callbacks )
								callbacks();
							opener.location.reload();
						}
					}
			);
		}

		// 컬럼추가 ( 장비 / 부품 / 버킷 )
		function fnAdd(data){
			console.log(data)
			if ( data== null ) {// 버킷추가
				if( fnCheckGridEmpty(0) && checkedEditableColumns(1) == -1 ) { // 필수값 / 다른 그리드가 수정중인지 확인
					var item = {
						machine_bucket_seq : 0,
						bucket_name : "",
						remark : "",
						use_yn : 'Y',
						bukkit_count : 0,
						sort_no : 99,
					};
					AUIGrid.addRow(auiGrids[0], item, "last");
				}
			}else{ // 호환모델/ 품
				if (data.length){ // 부품
					for (var idx in data){
						var part = data[idx];
						var item = {
							part_no : part.part_no,
							machine_bucket_seq : bukkit_idx,
							machine_plant_seq : match_idx,
							bucket_size_bms : '',
							base_yn : 'N',
						};
						AUIGrid.addRow(auiGrids[2], item, "last");
					}
				}else{ // 장비
					var machine = data;
					if ( bucketMachne[machine.machine_plant_seq] ){
						alert("이미 추가된 장비입니다.");
						return;
					}
					match_idx = machine.machine_plant_seq; // 자동선택
					AUIGrid.addRow(auiGrids[1], machine, "last");
					AUIGrid.setGridData(auiGrids[2], []); // 부품 비워주기
				}
			}
		}

		function addModel() { // 장비추가
			if ( bukkit_idx != -1)
				openSearchModelPanel('fnAdd', 'N');
			else alert("장비를 추가하기 전에 버킷을 선택 해 주세요.");
		}

		function addPart(){ // 부품추가
			if ( match_idx != -1)
				openSearchPartPanel('fnAdd', 'Y');
			else alert("부품을 추가하기 전에 호환모델을 선택 해 주세요.");
		}



		/**
		 * 변경값 확인
		 * @param idx
		 * @returns {number}
		 */
		function checkedEditableColumns(idx){
			for ( var i = idx; i < auiGrids.length; i++ ) {
				var j = fnChangeGridDataCnt(auiGrids[i]);
				if ( j != 0 ) return j;
			}
			return -1;
		}

		function fnCheckValue(newValue) {
			var gridData = AUIGrid.getGridData(auiGridLeft);
			if(gridData.length == 1 && newValue != '') {
				if(newValue < gridData[0].current_stock) {
					return true;
				}
			}
		}

		/**
		 * 그리드 필수 값 확인
		 * @param idx
		 * @returns {*}
		 */
		function fnCheckGridEmpty(idx) {
			var checkColumns = [ // 체크값
					["bucket_name", "sort_no"],
					[],
					["bucket_size_bms"],
			];

			for (var i = idx; i < checkColumns.length; i++) {
				if( !AUIGrid.validateGridData(auiGrids[idx], checkColumns[idx], "필수 항목은 반드시 값을 입력해야합니다.")){
					return false;
				}
			}
			return true;
		}

		// 닫기
		function fnClose() {
			window.close();
		}

	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<div class="content-wrap">

			<!-- 검색영역 -->
			<div class="search-wrap mt10">
				<table class="table table-fixed">
					<colgroup>
						<%-- 메이커 --%>
						<col width="60px">
						<col width="90px">
						<%-- 모델 --%>
						<col width="60px">
						<col width="90px">
						<%-- 사용여부 --%>
						<col width="60px">
						<col width="90px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>메이커</th>
						<td>
							<select id="s_maker_cd" name="s_maker_cd" class="form-control">
								<option value="">- 전체 -</option>
								<c:forEach items="${codeMap['MAKER']}" var="item">
									<c:if test="${item.code_v2 == 'Y'}">
										<option value="${item.code_value}">${item.code_name}</option>
									</c:if>
								</c:forEach>
							</select>
						</td>
						<th>모델명</th>
						<td>
							<input type="text" id="s_model" name="s_model"  class="form-control" value="">
						</td>
						<th>사용여부</th>
						<td>
							<select id="s_use_yn" name="s_use_yn" class="form-control">
								<option value="">- 전체 -</option>
								<option value="Y">사용</option>
								<option value="N">미사용</option>
							</select>
						</td>
						<td>
							<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();" >조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /검색영역 -->
			<%-- 그리드들 --%>
			<div class="row">
				<div class="col-5">
					<div class="title-wrap">
						<h4>버킷</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_L"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid0" style="margin-top: 5px; height: 300px;"></div>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_L"/></jsp:include>
						</div>
					</div>
				</div>
				<div class="col-4">
					<div class="title-wrap">
						<h4>호환모델</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" class="btn btn-info" onclick="javascript:addModel()">호환모델추가</button>
							</div>
						</div>
					</div>
					<div id="auiGrid1" style="margin-top: 5px; height: 300px;"></div>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_M"/></jsp:include>
						</div>
					</div>
				</div>
				<div class="col-3">
					<div class="title-wrap">
						<h4>품번</h4>
						<div class="btn-group">
							<div class="right">
								<button type="button" class="btn btn-info" onclick="javascript:addPart()">부품추가</button>
							</div>
						</div>
					</div>
					<div id="auiGrid2" style="margin-top: 5px; height: 300px;"></div>
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>