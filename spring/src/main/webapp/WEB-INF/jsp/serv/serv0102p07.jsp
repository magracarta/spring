<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 정비 > 서비스일지 > null > 고장부위
-- 작성자 : 성현우
-- 최초 작성일 : 2020-11-03 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>

	var auiGridLeft;
	var auiGridRight;
	$(document).ready(function() {
		// AUIGrid 생성
		createAUIGridLeft();
		createAUIGridRight();
	});
	
	//그리드생성
	function createAUIGridLeft() {
		var gridPros = {
			// rowIdField 설정
			rowIdField : "_$uid",
			// rowNumber
			showRowNumColumn: false,
			// 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
			wrapSelectionMove : false,
			enableFilter :true,
			enableSorting : false
		};
		var columnLayout = [
			{
				headerText : "분류",
				dataField : "break_part_name",
				width : "100%",
				style : "aui-left aui-link",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "고장부위번호",
				dataField : "break_part_seq",
				visible : false
			},
			{
				headerText : "고장부위코드",
				dataField : "break_part_code",
				visible : false
			},
			{
				headerText : "뎁스",
				dataField : "break_part_depth",
				visible : false
			}
		];

		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridLeft, ${list});
		
		$("#auiGridLeft").resize();

		AUIGrid.bind(auiGridLeft, "cellClick", function(event) {
			console.log(event.item);

			$M.setValue("break_part_seq", event.item.break_part_seq);
			$M.setValue("break_part_depth", event.item.break_part_depth);
			goSearchDetail();
		});
	}

	function goSearchDetail() {
		var param = {
			"s_break_part_seq": $M.getValue("break_part_seq"),
			"s_break_part_depth" : $M.getValue("break_part_depth")
		};

		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						AUIGrid.setGridData(auiGridRight, result.list);
					}
				}
		);
	}
	
	//그리드생성
	function createAUIGridRight() {
		var gridPros = {
			rowIdField : "_$uid",
			showRowNumColumn: false,
			// 체크박스 출력 여부
			showRowCheckColumn : true,
			// 전체선택 체크박스 표시 여부
			showRowAllCheckBox : true,
			showRowNumColumn: true,
			enableFilter :true
		};
		var columnLayout = [
			{ 
				headerText : "관리코드",
				dataField : "mng_code",
				style : "aui-center",
				width : "10%",
			},
			{
				headerText : "고장원인",
				dataField : "mng_name",
				style : "aui-left",
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "고장부위번호",
				dataField : "break_part_seq",
				visible : false
			}
		];
		
		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
		AUIGrid.setGridData(auiGridRight, ${listDetail});
		$("#auiGridRight").resize();
	}

	// 적용
	function goApplyInfo() {
		var checkedData = AUIGrid.getCheckedRowItems(auiGridRight);
		if(checkedData.length == 0) {
			alert("적용할 데이터를 체크해주세요.");
			return;
		}

		try {
			opener.${inputParam.parent_js_name}(checkedData);
			window.close();
		} catch(e) {
			alert("호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.");
		}
	}

	// 닫기
    function fnClose() {
    	window.close();
    }
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<input type="hidden" id="break_part_seq" name="break_part_seq">
<input type="hidden" id="break_part_depth" name="break_part_depth">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="contents">
				<div class="row">
					<div class="col" style="width: calc(80% - 24px);">
						<div class="row">
							<div class="col" style="width: 20%">
								<!-- 지역선택 -->
								<div class="title-wrap mt10">
									<h4>분류</h4>
								</div>
								<div id="auiGridLeft" style="margin-top: 5px; height: 550px;"></div>
							</div>
							<div class="col" style="width: calc(80% - 24px);">
								<div class="title-wrap mt10">
									<h4>고장원인</h4>
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
								</div>
								<div id="auiGridRight" style="margin-top: 5px; height: 550px;"></div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="btn-group mt10">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
		</div>
	</div>
	<!-- /contents 전체 영역 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>