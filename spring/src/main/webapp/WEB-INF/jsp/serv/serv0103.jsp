<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 정비Tool관리 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-07-15 15:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
	var auiGridTop;
	var auiGridBom;
	var gridRowIndex;
	var centerToolBoxList;
	var centerToolCheckDt;

	$(document).ready(function() {
		console.log('${page.fnc.F00698_001}');
		console.log('${SecureUser.org_type}');


		// AUIGrid 생성
		fnInit();
		fnSetToolCheckDt();										//센터별 조사일자목록
		createAUIGridTop();
		createAUIGridBom();
		fnSyncAUIGridScroll(auiGridTop,auiGridBom,"Y","Y");		//그리드 동기화


		$("#btnHideTop").children().eq(0).attr('id','btnAddToolCheck');
		$("#btnHideTop").children().eq(1).attr('id','btnCarryBeforeToolCheck');

		$("#btnHideBottom").children().eq(0).attr('id','btnRequest');
		$("#btnHideBottom").children().eq(1).attr('id','btnCompleteApproval');

	});


	function fnInit() {
		centerToolBoxList = ${centerToolBoxList};
		centerToolCheckDt = ${centerToolCheckDt};
	}

	function fnSetToolCheckDt(){

		if($M.getValue("s_center_org_code")!= ""){

			// select box 옵션 전체 삭제
			$("#s_tool_check_dt option").remove();

			//센터별 조사일지 리스트 적용
			for(i = 0; i< centerToolCheckDt.length; i++){
				var result = centerToolCheckDt[i];
				var checkDt = result.check_dt;
				var apprWrc = result.appr_wrc;
				var apprWrcName =  result.appr_wrc_name;

				var optVal = checkDt;
				var optText = $M.dateFormat($M.toDate(checkDt),'yyyy-MM-dd') + '  ' + apprWrcName;

				$('#s_tool_check_dt').append('<option value="'+ optVal +'">'+ optText +'</option>');
	        }
		}
	}



	// 그리드생성
	function createAUIGridTop() {
		var gridPros = {
			editable : true,
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			showRowNumColumn: true
		};
		var columnLayout = [
			{
				dataField : "org_code",
				visible : false
			},
			{
				dataField : "check_dt",
				visible : false
			},
			{
				dataField : "svc_tool_seq",
				visible : false
			},
			{
				headerText : "공구이름",
				dataField : "tool_name",
				style : "aui-left",
				width : "15%",
				editable : false
			},
			{
				headerText : "이미지",
				dataField : "file_seq",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {

						//이미지가 있는경우 상세보기 ( 파일업로드 공통모듈)
						gridRowIndex = event.rowIndex;

						if(event.item.file_seq > 0) {
							fnFileDragAndDrop(event.item.file_seq);
						}

					},

				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {

					if( value == "" || value == 0 ){
						return '이미지없음'
					}
					else {
						return '보기'
					}

				},
				style : "aui-center",
				width : "5%",
				editable : false

			},
			{
				headerText : "이전수량",
				dataField : "before_check_qty_sum",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "조사수량",
				dataField : "check_qty_sum",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "차이수량",
				dataField : "gap_qty_sum",
				style : "aui-center",
				editable : false
			},
			{
				headerText : "차이발생이유",
				dataField : "gap_remark",
				style : "aui-left  aui-editable",
				width : "15%",
				editable : true,
				editRenderer : {
				      type : "InputEditRenderer",
				      maxlength : 100,
				      // 에디팅 유효성 검사
				      validator : AUIGrid.commonValidator
				}
			}
		];

		auiGridTop = AUIGrid.create("#auiGridTop", columnLayout, gridPros);
		//// AUIGrid.setFixedColumnCount(auiGridTop, 5);
		AUIGrid.setGridData(auiGridTop, []);

		if($M.getValue("appr_wrc") == "W")
		{

			for (var i = 0; i < centerToolBoxList.length; ++i) {
				var result = centerToolBoxList[i];
				var columnObj = {
					headerText : result.svc_tool_box_name,
					dataField : "box" + result.svc_tool_box_cd,
					style : "aui-center aui-editable",
					width : "8%",
					editable : true,
					editRenderer : {
					    onlyNumeric : true,
					    allowPoint : false // 소수점(.) 입력 가능 설정
					}
				}

				AUIGrid.addColumn(auiGridTop, columnObj, 'last');
			}
		}
		else {
			for (var i = 0; i < centerToolBoxList.length; ++i) {
				var result = centerToolBoxList[i];
				var columnObj = {
					headerText : result.svc_tool_box_name,
					dataField : "box" + result.svc_tool_box_cd,
					style : "aui-center",
					width : "8%",
					editable : false,
					editRenderer : {
					    onlyNumeric : true,
					    allowPoint : false // 소수점(.) 입력 가능 설정
					}
				}

				AUIGrid.addColumn(auiGridTop, columnObj, 'last');
			}
		}
		$("#auiGridTop").resize();


		AUIGrid.bind(auiGridTop, "cellEditBegin", function( event ) {
			if(event.dataField == "gap_remark") {

				if($M.getValue("appr_wrc") == "W")
				{
					// 차이수량이 0아닌 경우에만 에디팅허용
					if(event.item.gap_qty_sum != 0) {
						return true;
					} else {
						return false;
					}
				}
				else {	//결제요청,결제완료시 실사수량 수정 불가
					return false;
				}
			}

		});

		AUIGrid.bind(auiGridTop, "cellEditEnd", function( event ) {
			//공구함별 공구의 재고 변경시 조사수량 , 차이수량 변경하기
			if(event.dataField != "gap_remark") {

				//변경값 - 원래값 ( 공구함별 공구재고)
				var gapValue = event.value - event.oldValue;

				//수량이 변결될때만
				if ( event.value != event.oldValue ) {
					// 조사수량,차이수량 갱신
				   	AUIGrid.updateRow(auiGridTop, { "check_qty_sum" : event.item.check_qty_sum + gapValue}	, event.rowIndex );
				   	AUIGrid.updateRow(auiGridTop, { "gap_qty_sum" 	: event.item.gap_qty_sum + gapValue}	, event.rowIndex );
				}
			}
		});


	}

	// 미결사항 그리드
	function createAUIGridBom() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowIdField가 unique 임을 보장
			rowIdTrustMode : true,
			showRowNumColumn: true
		};
		var columnLayout = [
			{
				dataField : "org_code",
				visible : false
			},
			{
				dataField : "check_dt",
				visible : false
			},
			{
				headerText : "공구이름",
				dataField : "tool_name",
				style : "aui-left",
				width : "15%"
			},
			{
				headerText : "이미지",
				dataField : "file_seq",
				renderer : {
					type : "ButtonRenderer",
					onClick : function(event) {

						//이미지가 있는경우 상세보기 ( 파일업로드 공통모듈)
						gridRowIndex = event.rowIndex;

						if(event.item.file_seq > 0) {
							fnFileDragAndDrop(event.item.file_seq);
						}

					},

				},
				labelFunction : function(rowIndex, columnIndex, value,
						headerText, item) {

					if( value == "" || value == 0 ){
						return '이미지없음'
					}
					else {
						return '보기'
					}

				},
				style : "aui-center",
				width : "5%",
				editable : false

			},
			{
				headerText : "이전수량",
				dataField : "before_check_qty_sum",
				style : "aui-center"
			},
			{
				headerText : "조사수량",
				dataField : "check_qty_sum",
				style : "aui-center"
			},
			{
				headerText : "차이수량",
				dataField : "gap_qty_sum",
				style : "aui-center"
			},
			{
				headerText : "차이발생이유",
				dataField : "gap_remark",
				style : "aui-left",
				width : "15%"
			}
		];

		auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
		//// AUIGrid.setFixedColumnCount(auiGridBom,  5);
		AUIGrid.setGridData(auiGridBom, []);


		for (var i = 0; i < centerToolBoxList.length; ++i) {
			var result = centerToolBoxList[i];
			var columnObj = {
					headerText : result.svc_tool_box_name,
					dataField : "box" +  result.svc_tool_box_cd,
					style : "aui-center",
					width : "8%",
					editable : true,
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) {
						var retStr = value;
						return retStr;
					}
			}
			AUIGrid.addColumn(auiGridBom, columnObj, 'last');
		}


		$("#auiGridBom").resize();

	}

	//조사일자목록 리스트 가져오기 ( 센터별)
	function  goSearchToolCheckDt() {

		if($M.getValue("s_center_org_code") == ""){
			$("select#s_tool_check_dt option").remove();
		}
		else {
			//센터를 변경하는 경우
			$("select#s_tool_check_dt option").remove();
			goSearch();
		}
	}


	// 조회
	function goSearch() {

		if($M.getValue("s_center_org_code") == ""){
			alert("센터를 선택해 주세요");
			return;
		}

		var param = {
				s_center_org_code 	: $M.getValue("s_center_org_code"),
				s_tool_check_dt 	: $M.getValue("s_tool_check_dt"),
				s_before_check_dt 	: $M.getValue("s_before_check_dt"),
				s_sort_method 		: "asc"
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
			function (result) {
				if (result.success) {

					$M.setValue("appr_wrc",result.appr_wrc);
					centerToolBoxList = result.centerToolBoxList;
					centerToolCheckDt = result.centerToolCheckDt;

					fnSetToolCheckDt();

					destroyGrid();
					createAUIGridTop();
					createAUIGridBom();
					fnSyncAUIGridScroll(auiGridTop,auiGridBom,"Y","Y");		//그리드 동기화

					AUIGrid.setGridData(auiGridTop, result.tookCheckList);
					AUIGrid.setGridData(auiGridBom, []);
					AUIGrid.setGridData(auiGridBom, result.prevToolCheckList);

					$("#appr_wrc_name").html("");
					$("#check_dt").html("");
					$("#before_appr_wrc_name").html("");
					$("#before_check_dt").html("");

					$("#appr_wrc_name").html(result.appr_wrc_name);
					$("#check_dt").html(result.check_date);
					$("#before_appr_wrc_name").html(result.before_appr_wrc_name);
					$("#before_check_dt").html(result.before_check_date);



					if(result.appr_wrc_name == "미마감"){
						$("#btnCompleteApproval").css({
				            display: "none"
				        });

						$("#btnRequest,#btnCarryBeforeToolCheck").css({
				            display: ""
				        });
					}


					if(result.appr_wrc_name == "결제요청" ){

						$("#btnRequest,#btnCarryBeforeToolCheck").css({
				            display: "none"
				        });

						$("#btnCompleteApproval").css({
				            display: ""
				        });
					}

					if(result.appr_wrc_name == "결제완료" ){
						$("#btnRequest,#btnCompleteApproval,#btnCarryBeforeToolCheck").css({
				            display: "none"
				        });

					}
				}
			}
		);
	}

	// 그리드 초기화
	function destroyGrid() {
		AUIGrid.destroy("#auiGridTop");
		AUIGrid.destroy("#auiGridBom");
		auiGridTop = null;
		auiGridBom = null;

	};

	// 파입업로드(드래그앤드랍)
	function fnFileDragAndDrop(fileSeq) {
		var param = {
		   'upload_type': 'SERVICE',
		   // 'max_width': '',
		   // 'max_height': '',
		   'pixel_limit_yn': '',
		   'max_size': '1000',
		   'size_limit_yn': '',
		   'file_type': 'img',
		   'file_seq': fileSeq,
		   'view_only_yn': 'Y'
		};

		openFileUploadPanel('setSaveFileInfo', $M.toGetParam(param));
	}

	function setSaveFileInfo(result) {


	}


	function fnDownloadExcel() {
		  // 엑셀 내보내기 속성
		  var exportProps = {
		         // 제외항목
		         //exceptColumnFields : ["removeBtn"]
		  };
		  fnExportExcel(auiGridTop, "정비Tool관리(선택목록)", exportProps);
		  fnExportExcel(auiGridBom, "정비Tool관리(직전목록)", exportProps);
	}

	// 조사일자추가
	function goAddToolCheckDt() {

		if($M.getValue("s_center_org_code") == ""){
			alert("조사일자 추가할 센터를 선택해 주세요");
			return;
		}

		var msg = "조사일지를 추가하시겠습니까?"

		var param = {
				s_center_org_code 	: 	$M.getValue("s_center_org_code"),
				org_code 			: 	$M.getValue("s_center_org_code"),
				check_dt			:	$M.getCurrentDate(),
				appr_wrc    		:   "W"
		};


		$M.goNextPageAjaxMsg(  msg ,this_page + "/insertSvcToolCheck", $M.toGetParam(param), {method: "POST"},
			function (result) {
				if (result.success) {
					//조사일지 추가후 그리드 다시 그리기
					goSearchToolCheckDt();
				}
			}
		);
	}

	// 이전 수량 이월
	function goCarryBeforeCheckTool() {

		if($M.getValue("s_center_org_code") == ""){
			alert("센터를 선택해 주세요");
			return;
		}

		var msg = "결제요청 또는 완료건 중 가장 최신건이 이월됩니다. \r\n 진행하시겠습니까?"

		var param = {
				s_center_org_code 	: $M.getValue("s_center_org_code"),
				s_tool_check_dt 			: $M.getValue("s_tool_check_dt")

		};


		$M.goNextPageAjaxMsg( msg ,this_page + "/carryBeforeToolCheck", $M.toGetParam(param), {method: "POST"},
				function (result) {
					if (result.success) {
						//조사일지 추가후 그리드 다시 그리기
						goSearchToolCheckDt();

					}
				}
			);
	}

	// 공구함관리
	function goToolBoxMngPopup() {
	   	var param = {
	   			s_center_org_code 	: $M.getValue("s_center_org_code")
		};
	   	openToolBoxMngPanel('setToolBoxMngInfo', $M.toGetParam(param));
	}

	// 공구관리
	function goToolMngPopup() {
	   	var param = {

		};

	   	openToolMngPanel('setToolMngInfo', $M.toGetParam(param));
	}

	// 센터공구실사 사진관리
	function goToolCheckFileMngPop() {

		if($M.getValue("s_center_org_code") == ""){
			alert("센터를 선택해 주세요.");
			return;
		}

		if($M.getValue("s_tool_check_dt") == ""){
			alert("조사일자를 선택해주세요.");
			return;
		}

	   	var param = {
	   			s_center_org_code 	: $M.getValue("s_center_org_code"),
	   			s_center_org_name 	: $("#s_center_org_code option:selected").text(),
	   			s_tool_check_dt 	: $M.getValue("s_tool_check_dt")

		};

	   	var requiredArray = ["s_center_org_code","s_tool_check_dt"];
		var msg = checkPanelParam('setChkToolFileInfo', requiredArray, $M.toGetParam(param));

		if(msg != '') {
			alert(msg);
			return;
		}

		$M.goNextPage('/serv/serv0103p06', $M.toGetParam(param), {popupStatus : getPopupProp(500, 630)});

	}

	// 센터공구실사 사진등록
	function goToolCheckFileRegPop() {


	   	var param = {
	   			s_center_org_code 	: $M.getValue("s_center_org_code"),
	   			s_center_org_name 	: $("#s_center_org_code option:selected").text(),
	   			s_tool_check_dt 	: $M.getValue("s_tool_check_dt")
		};

		var requiredArray = ["s_center_org_code","s_tool_check_dt"];
		var msg = checkPanelParam('setChkToolFileInfo', requiredArray, $M.toGetParam(param));

		if(msg != '') {
			alert(msg);
			return;
		}

		$M.goNextPage('/serv/serv0103p07', $M.toGetParam(param), {popupStatus : getPopupProp(550, 450)});

	}

    function setReload() {
		goSearch();
    }

    function setToolBoxMngInfo(data) {
		goSearch();
    }

    function setToolMngInfo(data) {
    	goSearch();
    }


	// 공구재고실사 결재요청
	function goRequest() {

		if($M.getValue("s_center_org_code") == ""){
			alert("센터를 선택해 주세요");
			return;
		}

		var frm = $M.toValueForm(document.main_form);

		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getGridData(auiGridTop);
		if(gridAllList.length < 1 ){
			alert("결제요청할 정보가 없습니다.");
			return;
		}

		for (var i = 0; i < gridAllList.length; i++) {

			if( gridAllList[i].gap_qty_sum != 0 && gridAllList[i].gap_remark == '' ) {
				AUIGrid.showToastMessage(auiGridTop, i, 6, "차이수량이 있는경우 차이발생이유 값은 필수값입니다.");
				return;
			}
		}

		// 그리드 데이터 저장
		var rowCount = fnChangeGridDataCnt(auiGridTop);

		if(rowCount > 0) {
			var gridForm = fnChangeGridDataToForm(auiGridTop);

			console.log(gridForm);

			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);
		} else {
			gridForm = frm;
		}

		var msg = "요청 후 내용변경을 불가능합니다. \r\n 요청 하시겠습니까?"

		$M.goNextPageAjaxMsg( msg ,this_page + "/toolCheckApprRequest", gridForm , {method: "POST"},
				function (result) {
					if (result.success) {
						//조사일지 추가후 그리드 다시 그리기
						goSearch();
						fnSetToolCheckDt();
					}
				}
			);

	}

	// 공구재고실사  결재처리
	function goCompleteApproval() {

		var param = {

				s_center_org_code : $M.getValue("s_center_org_code"),
				s_tool_check_dt : $M.getValue("s_tool_check_dt")
		}

		if($M.getValue("s_center_org_code") == ""){
			alert("센터를 선택해 주세요");
			return;
		}

		var frm = $M.toValueForm(document.main_form);

		// 화면에 보여지는 그리드 데이터 목록
		var gridAllList = AUIGrid.getGridData(auiGridTop);
		if(gridAllList.length < 1 ){
			alert("결제할 정보가 없습니다.");
			return;
		}

		var msg = "결제 후 취소할 수 없습니다.. \r\n 처리하시겠습니까?"

			$M.goNextPageAjaxMsg( msg ,this_page + "/toolCheckApprProcess", $M.toGetParam(param), {method: "POST"},
					function (result) {
						if (result.success) {
							//조사일지 추가후 그리드 다시 그리기
							goSearch();
							fnSetToolCheckDt();
						}
					}
				);

	}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
					<input type="hidden" id="center_org_code" 	name="center_org_code" value="${inputParam.s_center_org_code}" />
					<input type="hidden" id="appr_wrc" 	name="appr_wrc" value="" />

<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="100px">
								<col width="90px">
								<col width="180px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>센터</th>
									<td>
										<!-- 센터일 경우, 소속 센터만 조회가능하므로 셀렉트박스로 안함. -->
<%--										<c:if test="${SecureUser.org_type ne 'BASE' and SecureUser.mem_no ne 'MB00000525'}"> <!-- 최승희 대리 요청(김훈철 대리 센터목록 조회 가능) -->--%>
										<c:if test="${page.fnc.F00698_001 ne 'Y'}">
											<input type="text" class="form-control" value="${SecureUser.org_name}" readonly="readonly">
											<input type="hidden" value="${SecureUser.org_code}" id="s_center_org_code" name="s_center_org_code" readonly="readonly">
										</c:if>
										<!-- 본사의 경우, 전체 센터목록 선택가능 -->
<%--										<c:if test="${SecureUser.org_type eq 'BASE' || SecureUser.mem_no eq 'MB00000525'}"> <!-- 최승희 대리 요청(김훈철 대리 센터목록 조회 가능) -->--%>
										<c:if test="${page.fnc.F00698_001 eq 'Y'}">
											<select class="form-control" id="s_center_org_code" name="s_center_org_code" onchange="javascript:goSearchToolCheckDt();" >
												<option value="">- 전체 -</option>
												<c:forEach var="item" items="${orgCenterList}">
													<option value="${item.org_code}" <c:if test="${item.org_code==inputParam.s_center_org_code}">selected</c:if>>${item.org_name}</option>
												</c:forEach>
											</select>
										</c:if>
									</td>
									<th>조사일자목록</th>
									<td>
										<select class="form-control" id="s_tool_check_dt" name="s_tool_check_dt" >
										</select>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 2020-06-24 미마감 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4><span id="check_dt" name="check_dt" ></span> <span id="appr_wrc_name" name="appr_wrc_name" ></span></h4>
						<div class="btn-group">
							<div class="right" id="btnHideTop"  >
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGridTop" style="margin-top: 5px; height: 300px;"></div>
<!-- /2020-06-24 미마감 -->	

<!-- 2020-03-11 결재완료 -->
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4><span id="before_check_dt" name="before_check_dt" ></span> <span id="before_appr_wrc_name" name="before_appr_wrc_name" ></span> </h4>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div id="auiGridBom" style="margin-top: 5px; height: 300px;"></div>
					<div class="btn-group mt5">
						<div class="right" id="btnHideBottom"  >
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /2020-03-11 결재완료 -->

				</div>						
			</div>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>