<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 재고관리 > 바코드출력관리 > null > null
-- 작성자 : 황빛찬
-- 최초 작성일 : 2020-02-12 14:22:17
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	// 사용자 부품창고 세팅
	var	s_warehouse_cd = "${SecureUser.org_code}";
	var page = 1;
	var moreFlag = "N";
	var isLoading = false;
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		fnInit();
	});
	
	function fnInit() {
		// 해당 탭의 콤보그리드 정보를 다시 세팅해줘야함. (iframe 사용시 탭의 정보를 다시 세팅해줘야함..)
		var options = {
				data : centerListData,
				idField : "code_value",
				textField : "code_name",
				columns : centerListCols,
				showHeader: true,
				panelWidth: "250",
				panelMaxHeight: "155",
				multiple: false,
				selectOnNavigation: true,
				separator: ", ",
				selectOnCheck: false,
				checkOnSelect: false
		};

		$M.setEasyCombogrid("s_warehouse_cd", options, "goSearch()");
		$M.setValue("s_warehouse_cd", s_warehouse_cd);
	}
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "part_storage_seq",
			rowIdTrustMode : true,
			//체크박스 출력 여부
			showRowCheckColumn: true,
			//전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			showRowNumColumn: true,
			editable : true,
			enableFilter :true,
			showStateColumn : true
		};
		
		var columnLayout = [
			{
				headerText : "저장위치",
				dataField : "storage_name",
				width : "70%",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "매수",
				dataField : "output_count",
				width : "30%",
				style : "aui-center aui-editable",
				dataType : "numeric",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				}
			}
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
	}
	
	// 조회
	function goSearch() { 
// 		if( $M.getValue('startStorage') == '' && $M.getValue('endStorage') == '') {
// 			alert('시작위치 or 끝위치를 입력해주세요.');
// 			return;
// 		}

		// 조회 버튼 눌렀을경우 1페이지로 초기화
		page = 1;
		moreFlag = "N";
		fnSearch(function(result){
			AUIGrid.setGridData(auiGrid, result.list);
			$("#total_cnt").html(result.total_cnt);
			$("#curr_cnt").html(result.list.length);
			if (result.more_yn == 'Y') {
				moreFlag = "Y";
				page++;
			};
		});
	}
	
	// 조회버튼
	function fnSearch(successFunc) {
		console.log($M.getValue("startStorageSeq"));
		
		if ($M.getValue("s_warehouse_cd") == "") {
			alert("부품창고를 선택해 주세요.");
			return;
		}
		
		isLoading = true;
		var param = {
			s_warehouse_cd  : $M.getValue("s_warehouse_cd"),
			s_start_storage : $M.getValue("startStorage"),
			s_end_storage : $M.getValue("endStorage"),
			s_sort_key : "storage_name",
			s_sort_method : "asc",
			"page" : page,
			"rows" : $M.getValue("s_rows")
		};
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				isLoading = false;
				if(result.success) {
// 					$("#total_cnt").html(result.total_cnt);
// 					AUIGrid.setGridData(auiGrid, result.list);
					// 조회한 부품창고 세팅
					s_warehouse_cd = $M.getValue("s_warehouse_cd");
					successFunc(result);
				};
			}		
		);
	}
	
	// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
	function fnScollChangeHandelr(event) {
		if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
			goMoreData();
		};
	}
	
	function goMoreData() {
		fnSearch(function(result){
			result.more_yn == "N" ? moreFlag = "N" : page++;  
			if (result.list.length > 0) {
				console.log(result.list);
				AUIGrid.appendData("#auiGrid", result.list);
				$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
			};
		});
	}
	
    // 선택한 부품창고에 해당하는 저장위치 시작 목록 조회
    // 시작위치 조회 팝업
	function goStartStoragePopup() {
    	// 현재 선택되어있는 창고에 따른 저장위치 조회
		var param = {
    		warehouse_cd : $M.getValue("s_warehouse_cd"),
    		"storage_name" : $M.getValue("startStorage"),
    		"parent_js_name" : "fnStartStorage"
    	}
	    var poppupOption = "";
	    $M.goNextPage('/part/part0503p01/', $M.toGetParam(param) , {popupStatus : poppupOption});
	}
	
    function fnStartStorage(result) {
    	$M.getValue("startStorage") != "" ? "" : $("#clear-btn").toggleClass("dpn"); 
    	$M.setValue("startStorage", result.storage_name);
    }
    
	// 선택한 부품창고에 해당하는 저장위치 끝 목록 조회
	// 끝위치 조회 팝업
	function goEndStoragePopup() {
		var param = {
    		"warehouse_cd" : $M.getValue("s_warehouse_cd"),
    		"storage_name" : $M.getValue("endStorage"),
    		"parent_js_name" : "fnEndStorage"
    	}
	    var poppupOption = "";
	    $M.goNextPage('/part/part0503p01/', $M.toGetParam(param) , {popupStatus : poppupOption});
	}
	
    function fnEndStorage(result) {
    	$M.getValue("endStorage") != "" ? "" : $("#clear-btn2").toggleClass("dpn"); 
    	$M.setValue("endStorage", result.storage_name);
    }
    
    // 저장위치 지우기
    function fnClearStartStorage() {
    	$("#clear-btn").toggleClass("dpn");
    	$M.setValue("startStorage", null);
    }

    // 저장위치 지우기
    function fnClearEndStorage() {
    	$("#clear-btn2").toggleClass("dpn");
    	$M.setValue("endStorage", null);
    }
    
	function fnGetPageData() {
		// 그리드에 체크된 값 가져오기
		var rows = AUIGrid.getCheckedRowItemsAll(auiGrid);
		// 부모 함수호출 (프린터 호출)  rows : 프린터 연동을 위해 체크된 정보 함께 넘김.
 		//return parent.goPrintPopup(rows);
		for(var i = 0 ; i < rows.length ; i++){
			rows[i].org_name = $('#s_warehouse_cd').combobox('getText');
		}
		
		var newRows = [];
		// 매수만큼 데이터 반복
		for (var i in rows) {
			for (var j = 0; j < rows[i].output_count; j++) {
				newRows.push(rows[i]);
			}
		}
		return newRows;
	}
    
	// 엔터키 이벤트
	function enter(fieldObj) {
		var startField = ["startStorage"];
		var endField = ["endStorage"];
		$.each(startField, function() {
			if(fieldObj.name == this) {
				goStartStoragePopup();
			};
		});
		$.each(endField, function() {
			if(fieldObj.name == this) {
				goEndStoragePopup();
			};
		});
	}
	
	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
<!-- contents 전체 영역 -->
		<div class="content-box">
			<div class="contents">	
<!-- 메인 타이틀 -->
<!-- 검색영역 -->		
					<div class="search-wrap mt10" style="width : 60%">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="100px">
								<col width="70px">
								<col width="250px">
								<col width="*">
							</colgroup>
							<tbody>
								<tr>								
									<th>부품창고</th>
										<td>
											<input type="text" style="width : 140px";
												id="s_warehouse_cd" 
												name="s_warehouse_cd" 
												idfield="code_value"
												easyui="combogrid"
												header="Y"
												easyuiname="centerList" 
												panelwidth="250"
												maxheight="155"
												enter="goSearch()"
												textfield="code_name"
												multi="N"
												/>
										</td>
									<th>저장위치</th>
									<td>
										<div class="form-row inline-pd" style="width: 300px;">
											<div class="col" style="width: 135px;">
												<div class="input-group">
													<div class="icon-btn-cancel-wrap" style="width : calc(100% - 24px);">
														<input name="startStorage" id="startStorage" type="text" class="form-control border-right-0" placeholder="위치시작">
														<input name="startStorageSeq" id="startStorageSeq" type="hidden" class="form-control border-right-0" placeholder="위치시작">
<!-- 														<button type="button" class="icon-btn-cancel dpn" onclick="fnClearStartStorage()" id="clear-btn"><i class="material-iconsclose font-16 text-default"></i></button> -->
													</div>
													<button type="button" class="btn btn-icon btn-primary-gra"><i class="material-iconssearch" onclick="javascript:goStartStoragePopup()"></i></button>				
												</div>
											</div>
											<div class="col-auto pl5">~</div>
											<div class="col" style="width: 135px;">
												<div class="input-group">
													<div class="icon-btn-cancel-wrap" style="width : calc(100% - 24px);">
														<input name="endStorage" id="endStorage" type="text" class="form-control border-right-0" placeholder="위치끝">
<!-- 														<button type="button" class="icon-btn-cancel dpn" onclick="fnClearEndStorage()" id="clear-btn2"><i class="material-iconsclose font-16 text-default"></i></button> -->
													</div>
													<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goEndStoragePopup()"><i class="material-iconssearch"></i></button>				
												</div>
											</div>
										</div>
									</td>											
									<td class="">
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
									</td>
								</tr>								
							</tbody>
						</table>
					</div>
<!-- /검색영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 450px; width:60%"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>						
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
<!-- /contents 전체 영역 -->	
</form>
</body>
</html>