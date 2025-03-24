<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 인사코드관리 > null > 직책관리
-- 작성자 : 황빛찬
-- 최초 작성일 : 2021-10-21 19:04:05
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
	var auiGrid;
	
	$(document).ready(function () {
		// 그리드 생성
		createAUIGrid();
		goSearch();
		
		if("${save_yn}" == "N") {
			$("#_goSave").hide();
		}
	});
	
	function fnClose() {
		window.close();
	}
	
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "_$uid",
			rowIdTrustMode : true,
			showRowNumColumn: true,
			editable : true,
			enableFilter :true,
			showStateColumn : true
		};
		
		var columnLayout = [
			{
				dataField : "hr_job_seq",
				visible : false
			},
			{
				dataField : "grade_cd",
				visible : false
			},
			{
				headerText : "직책",
				dataField : "grade_name",
				width : "80",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "레벨",
				dataField : "biz_code",
				width : "70",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "등급",
				dataField : "biz_grade_hmb",
				width : "60",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "월 수당",
				dataField : "mon_benefit_amt",
				width : "120",
				style : "aui-right",
				dataType : "numeric",
				editRenderer : {
				      type : "InputEditRenderer",
				      onlyNumeric : true, // Input 에서 숫자만 가능케 설정
				},
				editable : false,
			},
			{
				headerText : "연 수당",
				dataField : "year_benefit_amt",
				width : "140",
				style : "aui-right",
				dataType : "numeric",
				editable : false,
				expFunction : function(  rowIndex, columnIndex, item, dataField ) {
					var amt = 0;
					// (Q&A 13200) SA2, M2는 인원수 곱함. 기획에있음. 21-11-29 김상덕.
					if (item.biz_code == "SA2" || item.biz_code == "M2") {
						amt = item.mon_benefit_amt * item.center_cnt * 12
					} else {
						amt = item.mon_benefit_amt * 12
					}
					return amt;
				}
			},
			{
				dataField : "center_cnt",
				visible : false
			},
			{
				headerText : "내용",
				dataField : "remark",
				width : "450",
				style : "aui-left",
				editable : false,
			},
			{
				headerText : "적용여부",
				dataField : "apply_yn",
				width : "80",
				style : "aui-center",
				renderer : {
					type : "CheckBoxEditRenderer",
					editable : true,
					checkValue : "Y",
					unCheckValue : "N"
				},
			},
		];
		
		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros)
		AUIGrid.setGridData(auiGrid, []);
		
		// 적용시 합계금액 세팅
		AUIGrid.bind(auiGrid, "cellEditEnd", function (event) {
			if (event.dataField == "apply_yn") {
				console.log("event : ", event);
				
				var totalAmt = $M.toNum($M.getValue("total_amt"));
				var thisAmt = event.item.mon_benefit_amt;
				
				// 합계세팅
				if (event.value == "Y") {
					totalAmt += thisAmt;
				} else {
					totalAmt -= thisAmt;
				}
				
				// 레벨세팅
				var gridData = AUIGrid.getGridData(auiGrid);
				for (var i = 0; i < gridData.length; i++) {
					if (gridData[i].apply_yn == 'Y') {
						$M.setValue("biz_code", gridData[i].biz_code);
					}
				}
				
				$M.setValue("total_amt", totalAmt);
				
				
			}
		});
	}
	
	function goSearch() {
		var param = {
				"mem_result_eval_no" : $M.getValue("mem_result_eval_no"),
				"mem_band_item_cd" : $M.getValue("mem_band_item_cd"),
				"mem_no" : '${inputParam.mem_no}'
		};
			
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if(result.success) {
					AUIGrid.setGridData(auiGrid, result.list);
					
					console.log("result : ", result);
					
					var list = result.list;
					var totalAmt = 0;
					for (var i = 0; i < list.length; i++) {
						if (list[i].apply_yn == 'Y') {
							totalAmt += list[i].mon_benefit_amt;
							$M.setValue("biz_code", list[i].biz_code);
						} 
					}
					
					console.log("totalAmt : ", totalAmt);
					$M.setValue("total_amt", totalAmt);
				};
			}		
		);
	}
	
	// 적용
	function goSave() {
		if (confirm("직책레벨 및 합계금액을 적용하시겠습니까?") == false) {
			return false;
		}
		
		var memResultEvalNoArr = [];
		var memBandItemCdArr = [];
		var hrJobSeqArr = [];
		var monBenefitAmtArr = [];
		
		var gridData = AUIGrid.getGridData(auiGrid);
		console.log("gridData : ", gridData);
		for (var i = 0; i < gridData.length; i++) {
			if (gridData[i].apply_yn == 'Y') {
				
				hrJobSeqArr.push(gridData[i].hr_job_seq);
				monBenefitAmtArr.push(gridData[i].mon_benefit_amt);
			}
		}		
		
		if (hrJobSeqArr.length == 0) {
			alert("적용항목이 없습니다.");
			return false;
		}

		var option = {
				isEmpty : true
		};
		
		var params = {
				mem_result_eval_no : $M.getValue("mem_result_eval_no"),
				mem_band_item_cd : $M.getValue("mem_band_item_cd"),
				hr_job_seq_str : $M.getArrStr(hrJobSeqArr, option),
				mon_benefit_amt_str : $M.getArrStr(monBenefitAmtArr, option)
		}
		
		console.log("params : ", params);
		
		$M.goNextPageAjax(this_page + "/save", $M.toGetParam(params) , {method : 'POST'},
			function(result) {
	    		if(result.success) {
	    			alert("저장이 완료되었습니다.");
	    			
					var param = {
							job_code : $M.getValue("biz_code"),
							job_amt : $M.getValue("total_amt"),
							rowIndex : ${inputParam.level_index}
					}
					
					console.log("param : ", param);
					
					opener.${inputParam.parent_js_name}(param);
					window.close();
				}
			}
		);
		
	}
	</script>
</head>
<body class="bg-white">
<input type="hidden" id="mem_result_eval_no" name="mem_result_eval_no" value="${inputParam.mem_result_eval_no}">
<input type="hidden" id="mem_band_item_cd" name="mem_band_item_cd" value="${inputParam.mem_band_item_cd}">
<!-- 팝업 -->
<div class="popup-wrap width-100per">
    <!-- 타이틀영역 -->
    <div class="main-title">
        <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
    </div>
    <!-- /타이틀영역 -->
    <div class="content-wrap">
        <!-- 그룹 영역 -->
        <div class="title-wrap">
            <h4>
             <span>직책 수당 관리</span>
             <span style="color: #ff7f00;" class="ml5">※ SA2, M2의 연수당 = 월수당 x 센터 인원수 x 12개월</span>
            </h4>
			<div class="btn-group">
				<div class="right dpf">
					<div class="ver-line mr10">레벨/합계 :</div>
					<input type="text" class="text-center width60px" id="biz_code" name="biz_code" readonly="readonly" value="${inputParam.biz_code}">
					<span style="width: 12px; text-align: center;">/</span>
					<input type="text" class="text-center width100px" id="total_amt" name="total_amt" format="decimal" readonly="readonly" value="${inputParam.total_amt}">
				</div>
			</div>
        </div>
        <div id="auiGrid" style="margin-top: 5px; height: 450px;"></div>
        <!-- /그룹 영역 -->
        <!-- 버튼 영역 -->
        <div class="btn-group mt10 mr5">
            <div class="right">
                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
            </div>
        </div>
        <!-- /버튼 영역 -->
    </div>
</div>
<!-- /팝업 -->
</body>
</html>